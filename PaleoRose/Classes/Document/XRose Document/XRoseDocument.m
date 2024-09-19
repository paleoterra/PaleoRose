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
#import "XRoseTableController.h"
#import "XRoseView.h"
#import "XRFileParser.h"
#import "XRoseTableController.h"
#import "XRExportGraphicAccessory.h"
#import "XRStatistic.h"
#import "XRMakeDatasetController.h"
#import "LITMXMLTree.h"
#import <Security/Security.h>
#import <Security/AuthSession.h>
#import "XRTableImporter.h"
#import <os/activity.h>
#import <PaleoRose-Swift.h>

@interface XRoseDocument()

@property (nonatomic) NSMutableArray *dataSets;
@property (nonatomic) LITMXMLTree *tempTree;

@property (nonatomic) NSObject *currentSheetController;
@property (nonatomic) XRTableImporter *tableImporter;

@property (nonatomic) NSMutableArray *tables;


//@property (readwrite) sqlite3* inMemoryStore;
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
        _documentModel = [[DocumentModel alloc] initInMemoryStore:[[InMemoryStore alloc] init]];
        [self createDB];
        _didLoad = NO;
	}
    return self;
}

#pragma mark - Reading the Document's Content

-(BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError * _Nullable __autoreleasing *)outError
{
    if([typeName isEqualToString:@"XRose"])
    {
        [self readInMemoryStoreToPath:[url path]];
        return YES;
    }
    return NO;
}

-(void)readInMemoryStoreToPath:(NSString *)sourcePath {
    int returnCode;
    sqlite3 *sourceFile;
    sqlite3_backup *sqliteBackup;

    //create target file
    returnCode = sqlite3_open([sourcePath cStringUsingEncoding:NSUTF8StringEncoding], &sourceFile);

    if (returnCode == SQLITE_OK) {
        sqliteBackup = sqlite3_backup_init([self.documentModel store], "main", sourceFile, "main");
        if (sqliteBackup) {
            (void)sqlite3_backup_step(sqliteBackup, -1);
            (void)sqlite3_backup_finish(sqliteBackup);
        }
    }
    sqlite3_close(sourceFile);
    self.didLoad = YES;
}

#pragma mark - Writing the Document's Content

-(BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError * _Nullable __autoreleasing *)outError
{
    NSString *fileName = [url path];//temp save path
    [[self.mainWindowController geometryController]  saveToSQLDB:[self.documentModel store]];
    [self.mainWindowController  saveToSQLDB:[self.documentModel store]];
    [(XRoseTableController *)[self.mainWindowController tableController] saveToSQLDB:[self.documentModel store]];
    [self writeInMemoryStoreToPath:fileName];
    return YES;
}

-(void)writeInMemoryStoreToPath:(NSString *)targetPath {
    int returnCode;
    sqlite3 *targetFile;
    sqlite3_backup *sqliteBackup;

    //create target file
    returnCode = sqlite3_open([targetPath cStringUsingEncoding:NSUTF8StringEncoding], &targetFile);

    if (returnCode == SQLITE_OK) {
        sqliteBackup = sqlite3_backup_init(targetFile, "main", [self.documentModel store], "main");
        if (sqliteBackup) {
            (void)sqlite3_backup_step(sqliteBackup, -1);
            (void)sqlite3_backup_finish(sqliteBackup);
        }
    }
    sqlite3_close(targetFile);

}

#pragma mark - Getting Document Metadata

#pragma mark - Managing File Type Information

#pragma mark - Creating and Manageing Window Controllers

-(void)makeWindowControllers
{
    XRoseWindowController *aController = [[XRoseWindowController alloc] initWithWindowNibName:@"XRoseDocument"];
    [self addWindowController:aController];
    _mainWindowController = aController;
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

-(void)awakeFromNib
{
    if(self.didLoad) {
        [self loadDatasetsFromDB:[self.documentModel store]];
        [[self.mainWindowController geometryController]  setValuesFromSQLDB:[self.documentModel store]];

        [self.mainWindowController  setValuesFromSQLDB:[self.documentModel store]];

        [(XRoseTableController *)[self.mainWindowController  tableController] configureControllerWithSQL:[self.documentModel store] withDataSets:self.dataSets];
    }
    else {

    }
    self.didLoad = NO;
}

#pragma mark - Accessors

-(sqlite3 *)documentInMemoryStore
{
    return [self.documentModel store];
}

-(NSArray *)tableList
{
    return self.tables;
}

#pragma mark - PR Window Controller Delegate

-(void)configureDocument
{
	if([self.documentModel store] != NULL)
	{
		[self.mainWindowController  setValuesFromSQLDB:[self.documentModel store]];
	}
	else
	{
		[self createDB];
	}
	[self.mainWindowController setTableList:self.tables];
	[self discoverTables];
}

-(void)addDataLayer:(id)sender
{
    os_activity_initiate("add data layer", OS_ACTIVITY_FLAG_DEFAULT, ^{
        [self loadDataSet];
    });
	
}

-(void)loadDataSet
{
    XRMakeDatasetController *controller;
    if([self fileURL])
        controller = [[XRMakeDatasetController alloc] initWithTableArray:self.tables inMemoryDocument:[self.documentModel store]];
    else
        controller = [[XRMakeDatasetController alloc] initWithTableArray:self.tables inMemoryDocument:[self.documentModel store]];
    self.currentSheetController = controller;
    [[self.mainWindowController window]
     beginSheet:[controller window]
     completionHandler:^(NSModalResponse returnCode) {
        if(returnCode == NSModalResponseOK)
        {
            XRDataSet *aSet;
            if([controller predicate])
                aSet = [[XRDataSet alloc] initWithTable:[controller selectedTable] column:[controller selectedColumn] forDocument:self  predicate:[controller predicate]];
            else
                aSet = [[XRDataSet alloc] initWithTable:[controller selectedTable] column:[controller selectedColumn] forDocument:self];
            [aSet setName:[controller selectedName]];
            if(aSet)
            {
                [self.dataSets addObject:aSet];
                [(XRoseTableController *)[self.mainWindowController tableController] addDataLayerForSet:aSet];
                //[[self undoManager] registerUndoWithTarget:[self.mainWindowController tableController] selector:@selector(deleteLayer:) object:[[self.mainWindowController tableController]lastLayer]];
                //[[self undoManager] setActionName:@"Add Data Layer"];
                [self updateChangeCount:NSChangeDone];
            }

        }
        self.currentSheetController = nil;
    }];
}

#pragma mark "Responder" Chain

-(IBAction)copyPDFImage:(id)sender
{
    [self.mainWindowController copyPDFToPasteboard];
}

-(IBAction)copyTIFFImage:(id)sender
{
    [self.mainWindowController copyPDFToPasteboard];
}

-(IBAction)exportImage:(id)sender
{
    NSSavePanel *sp = [NSSavePanel savePanel];
    XRExportGraphicAccessory *accessoryView = [XRExportGraphicAccessory exportGraphicAccessoryView];
    [accessoryView setDelegate:sp];
    [sp setAccessoryView:accessoryView];
    [sp setAllowedFileTypes:[NSArray arrayWithObjects:@"pdf",@"tif",@"jpg",@"PDF",@"TIF",@"JPG",nil]];
    //[sp setExtensionHidden:NO];
    NSString *baseName;
    if([self fileURL])
        baseName = [[[self fileURL] path ]stringByDeletingPathExtension];
    else
    {
        baseName = NSHomeDirectory();
        baseName = [baseName stringByAppendingPathComponent:[[self.mainWindowController window] title]];
    }
    [sp setDirectoryURL:[NSURL fileURLWithPath:[baseName stringByDeletingLastPathComponent]]];
    [sp beginSheetModalForWindow:[self.mainWindowController window] completionHandler:^(NSInteger result) {
        if(result == NSModalResponseOK)
        {
            NSData *targetData;
            if((targetData = [(XRoseView *)[self.mainWindowController mainView] imageDataForType:[[sp URL] pathExtension]]))
            {
                [[NSFileManager defaultManager] createFileAtPath:[[sp URL] path] contents:targetData attributes:nil];
            }
        }
    }];
}

-(IBAction)generateStatisticsReport:(id)sender
{
    NSSavePanel *sp = [NSSavePanel savePanel];
    __block NSString *basename = [[[self fileURL] path ]lastPathComponent];
    if(!basename)
        basename = [[self.mainWindowController window] title];
    [sp setAllowedFileTypes:@[@"txt"]];
    [sp setDirectoryURL:[[self fileURL] URLByDeletingLastPathComponent]];
    [sp beginSheetModalForWindow:[self.mainWindowController window] completionHandler:^(NSInteger result) {
        if(result == NSModalResponseOK)
        {
            NSMutableString *theString = [[NSMutableString alloc] init];
            [theString appendFormat:@"XRose STATISTICS REPORT FOR FILE: %@\n%@\n\n\n" ,[self fileURL] ,[[NSDate date] descriptionWithLocale:nil]];
            //now append general geometry issues
            [theString appendFormat:@"Geometry:\n\tSector Count: %i\n\tSector Size (degrees): %f\n\n",[(XRGeometryController *)[self.mainWindowController geometryController]  sectorCount],[(XRGeometryController *)[self.mainWindowController geometryController]  sectorSize]];
            //have table controller append info
            [theString appendString:[(XRoseTableController *)[self.mainWindowController tableController] generateStatisticsString]];
            if([[NSFileManager defaultManager] fileExistsAtPath:[[sp URL] path]])
                [[NSFileManager defaultManager] removeItemAtPath:[[sp URL] path] error:nil];
            [[NSFileManager defaultManager] createFileAtPath:[[sp URL] path] contents:[theString dataUsingEncoding:NSASCIIStringEncoding] attributes:nil];

            [[NSWorkspace sharedWorkspace] openFile:[[sp URL] path]  withApplication:@"TextEdit"];
        }
    }];
}

#pragma mark Data Sets

-(void)addDataSet:(XRDataSet *)aSet
{
    [self.dataSets addObject:aSet];
}

-(void)removeDataSet:(XRDataSet *)aSet
{
    [self.dataSets removeObject:aSet];
}

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

-(void)createDB
{
    int error;
    char *errorMsg;

    NSString *sqlStatement;


    /* At present, the window controller sets only width and height from saved values.  Thus, the
        window controller will only have 2 values - width and height */

    //create window controller table
    sqlStatement = @"CREATE TABLE _windowController ( height    float, width    float )";
    error = sqlite3_exec([self.documentModel store],[sqlStatement UTF8String],NULL,NULL,&errorMsg);
    if(error!=SQLITE_OK)
    {
        NSError *theError = [NSError errorWithDomain:@"SQLITE" code:error userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithUTF8String:errorMsg],nil]
                                                                                                               forKeys:[NSArray arrayWithObjects:@"NSLocalizedFailureReasonErrorKey",nil]]];
        [self presentError:theError];
    }

    //create geometryController table
    sqlStatement = @"CREATE TABLE _geometryController ( isEqualArea bool, isPercent bool, MAXCOUNT int, MAXPERCENT float, HOLLOWCORE float, SECTORSIZE float, STARTINGANGLE float, SECTORCOUNT int, RELATIVESIZE float)";
    error = sqlite3_exec([self.documentModel store],[sqlStatement UTF8String],NULL,NULL,&errorMsg);
    if(error!=SQLITE_OK)
    {
        NSError *theError = [NSError errorWithDomain:@"SQLITE" code:error userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithUTF8String:errorMsg],nil]
                                                                                                               forKeys:[NSArray arrayWithObjects:@"NSLocalizedFailureReasonErrorKey",nil]]];
        [self presentError:theError];
    }
    //create layers table
    sqlStatement = @"CREATE TABLE _layers ( LAYERID INTEGER, TYPE TEXT, VISIBLE bool, ACTIVE bool, BIDIR bool, LAYER_NAME TEXT, LINEWEIGHT float, MAXCOUNT int, MAXPERCENT float, STROKECOLORID INTEGER, FILLCOLORID INTEGER)";
    error = sqlite3_exec([self.documentModel store],[sqlStatement UTF8String],NULL,NULL,&errorMsg);
    if(error!=SQLITE_OK)
    {
        NSError *theError = [NSError errorWithDomain:@"SQLITE" code:error userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithUTF8String:errorMsg],nil]
                                                                                                               forKeys:[NSArray arrayWithObjects:@"NSLocalizedFailureReasonErrorKey",nil]]];
        [self presentError:theError];
    }
    //create colors table
    sqlStatement = @"CREATE TABLE _colors ( COLORID INTEGER PRIMARY KEY, RED float, BLUE float, GREEN float, ALPHA float)";
    error = sqlite3_exec([self.documentModel store],[sqlStatement UTF8String],NULL,NULL,&errorMsg);
    if(error!=SQLITE_OK)
    {
        NSError *theError = [NSError errorWithDomain:@"SQLITE" code:error userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithUTF8String:errorMsg],nil]
                                                                                                               forKeys:[NSArray arrayWithObjects:@"NSLocalizedFailureReasonErrorKey",nil]]];
        [self presentError:theError];
    }
    //create datasets table
    sqlStatement = @"CREATE TABLE _datasets ( _id INTEGER PRIMARY KEY, NAME TEXT, TABLENAME TEXT, COLUMNNAME text, PREDICATE text,COMMENTS BLOB)";
    error = sqlite3_exec([self.documentModel store],[sqlStatement UTF8String],NULL,NULL,&errorMsg);
    if(error!=SQLITE_OK)
    {
        NSError *theError = [NSError errorWithDomain:@"SQLITE" code:error userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithUTF8String:errorMsg],nil]
                                                                                                               forKeys:[NSArray arrayWithObjects:@"NSLocalizedFailureReasonErrorKey",nil]]];
        [self presentError:theError];
    }

    //create _layerText table
    sqlStatement = @"CREATE TABLE _layerText ( LAYERID INTEGER, CONTENTS BLOB, RECT_POINT_X float, RECT_POINT_Y float,RECT_SIZE_HEIGHT float,RECT_SIZE_WIDTH float)";
    error = sqlite3_exec([self.documentModel store],[sqlStatement UTF8String],NULL,NULL,&errorMsg);
    if(error!=SQLITE_OK)
    {
        NSError *theError = [NSError errorWithDomain:@"SQLITE" code:error userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithUTF8String:errorMsg],nil]
                                                                                                               forKeys:[NSArray arrayWithObjects:@"NSLocalizedFailureReasonErrorKey",nil]]];
        [self presentError:theError];
    }
    //create _layerLineArrow table
    sqlStatement = @"CREATE TABLE _layerLineArrow ( LAYERID INTEGER, DATASET integer, ARROWSIZE float, VECTORTYPE INTEGER,ARROWTYPE INTEGER,SHOWVECTOR bool,SHOWERROR bool)";
    error = sqlite3_exec([self.documentModel store],[sqlStatement UTF8String],NULL,NULL,&errorMsg);
    if(error!=SQLITE_OK)
    {
        NSError *theError = [NSError errorWithDomain:@"SQLITE" code:error userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithUTF8String:errorMsg],nil]
                                                                                                               forKeys:[NSArray arrayWithObjects:@"NSLocalizedFailureReasonErrorKey",nil]]];
        [self presentError:theError];
    }
    //create _layerCore table
    sqlStatement = @"CREATE TABLE _layerCore ( LAYERID INTEGER, RADIUS float, TYPE bool)";
    error = sqlite3_exec([self.documentModel store],[sqlStatement UTF8String],NULL,NULL,&errorMsg);
    if(error!=SQLITE_OK)
    {
        NSError *theError = [NSError errorWithDomain:@"SQLITE" code:error userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithUTF8String:errorMsg],nil]
                                                                                                               forKeys:[NSArray arrayWithObjects:@"NSLocalizedFailureReasonErrorKey",nil]]];
        [self presentError:theError];
    }
    //create _layerGrid table
    sqlStatement = @"CREATE TABLE _layerGrid ( LAYERID INTEGER, RINGS_ISFIXEDCOUNT bool, RINGS_VISIBLE bool, RINGS_LABELS bool,RINGS_FIXEDCOUNT  INTEGER, RINGS_COUNTINCREMENT INTEGER,RINGS_PERCENTINCREMENT  FLOAT, RINGS_LABELANGLE FLOAT, RINGS_FONTNAME text, RINGS_FONTSIZE float,RADIALS_COUNT INTEGER,RADIALS_ANGLE float,RADIALS_LABELALIGN integer,RADIALS_COMPASSPOINT integer,RADIALS_ORDER integer,RADIALS_FONT text,RADIALS_FONTSIZE float,RADIALS_SECTORLOCK bool, RADIALS_VISIBLE bool, RADIALS_ISPERCENT bool,RADIALS_TICKS bool,RADIALS_MINORTICKS bool,RADIALS_LABELS bool)";
    error = sqlite3_exec([self.documentModel store],[sqlStatement UTF8String],NULL,NULL,&errorMsg);
    if(error!=SQLITE_OK)
    {
        NSError *theError = [NSError errorWithDomain:@"SQLITE" code:error userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithUTF8String:errorMsg],nil]
                                                                                                               forKeys:[NSArray arrayWithObjects:@"NSLocalizedFailureReasonErrorKey",nil]]];
        [self presentError:theError];
    }
    //create _layerData table
    sqlStatement = @"CREATE TABLE _layerData ( LAYERID INTEGER, DATASET INTEGER, PLOTTYPE INTEGER, TOTALCOUNT INTEGER,DOTRADIUS  FLOAT)";
    error = sqlite3_exec([self.documentModel store],[sqlStatement UTF8String],NULL,NULL,&errorMsg);
    if(error!=SQLITE_OK)
    {
        NSError *theError = [NSError errorWithDomain:@"SQLITE" code:error userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithUTF8String:errorMsg],nil]
                                                                                                               forKeys:[NSArray arrayWithObjects:@"NSLocalizedFailureReasonErrorKey",nil]]];
        [self presentError:theError];
    }

    if([[self windowControllers] count]) {
        [self.mainWindowController SQLInitialSaveToDatabase:[self.documentModel store]];
        [[self.mainWindowController geometryController] SQLInitialSaveToDatabase:[self.documentModel store]];
    }

}

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

-(NSArray *)retrieveNonTextColumnNamesFromTable:(NSString *)aTableName
{
    sqlite3 *db = [self documentInMemoryStore];
    sqlite3_stmt *stmt;
    const char *pzTail;
    int error;
    NSMutableArray *theColumns = [[NSMutableArray alloc] init];

    error = sqlite3_prepare(db,[[NSString stringWithFormat:@"SELECT * FROM \"%@\" LIMIT 1",aTableName] UTF8String],-1,&stmt,&pzTail);
    if(error != SQLITE_OK)
    {
        NSError *theError = [NSError errorWithDomain:@"SQLITE" code:error userInfo:nil];
        [self presentError:theError];
        return nil;
    }
    while(sqlite3_step(stmt)==SQLITE_ROW)
    {
        int count = sqlite3_column_count(stmt);
        for(int i=0;i<count;i++)
        {
            int columnType = (int)sqlite3_column_type(stmt,i);
            NSString *columnName = [NSString stringWithUTF8String:(char *)sqlite3_column_name(stmt,i)];

            if((columnType < 3)||(columnType == 5))
                [theColumns addObject:columnName];


        }
    }
    sqlite3_finalize(stmt);

    return [NSArray arrayWithArray:theColumns];

}

-(void)discoverTables
{

    int error;

    sqlite3_stmt *stmt;
    const char *zSql;
    NSString *sql = @"select tbl_name from sqlite_master where type = \"table\" AND tbl_name NOT LIKE \"_w%\" AND tbl_name NOT LIKE \"_g%\" AND tbl_name NOT LIKE \"_l%\" AND tbl_name NOT LIKE \"_c%\" AND tbl_name NOT LIKE \"_d%\"";

    error = sqlite3_prepare([self.documentModel store],[sql UTF8String],-1,&stmt,&zSql);
    if(error == SQLITE_OK)
    {
        [self.tables removeAllObjects];
        while(sqlite3_step(stmt)!=SQLITE_DONE)
        {
            NSString *aString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt,0)];
            //NSLog(aString);
            if(![self.tables containsObject:aString])
                [self.tables addObject:aString];
        }
    }
    else
    {
        NSError *theError = [NSError errorWithDomain:@"SQLITE" code:error userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithUTF8String:(char *)sqlite3_errmsg([self.documentModel store])],nil]
                                                                                                               forKeys:[NSArray arrayWithObjects:@"NSLocalizedFailureReasonErrorKey",nil]]];
        [self presentError:theError];
    }
    sqlite3_finalize(stmt);
    [self.mainWindowController updateTable];
}

-(void)loadDatasetsFromDB:(sqlite3 *)db
{
    int error,count;
    const char *pzTail;
    sqlite3_stmt *stmt;
    XRDataSet *aSet;
    error = sqlite3_prepare(db,"SELECT count(*) FROM _datasets",-1,&stmt,&pzTail);
    if(error!=SQLITE_OK)
    {
        NSError *theError = [NSError errorWithDomain:@"SQLITE" code:error userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithUTF8String:(char *)sqlite3_errmsg(db)],nil]
                                                                                                               forKeys:[NSArray arrayWithObjects:@"NSLocalizedFailureReasonErrorKey",nil]]];
        [self presentError:theError];
    }
    count = 0;
    while(sqlite3_step(stmt)==SQLITE_ROW)
    {
        count = sqlite3_column_int(stmt,0);
    }
    sqlite3_finalize(stmt);

    for(int i=1;i<count+1;i++)
    {
        aSet = [[XRDataSet alloc] initFromSQL:db forIndex:i];
        [self.dataSets addObject:aSet];
        aSet = nil;
    }


}

#pragma mark Importing Data

-(void)importTable:(id)sender
{
    //NSLog(@"in importTable");
    NSOpenPanel *op = [NSOpenPanel openPanel];
    [op setAllowsMultipleSelection:NO]; //this should change as the code matures
    [op setAllowedFileTypes:[NSArray arrayWithObjects:@"txt",@"xml",@"XML",nil]];
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

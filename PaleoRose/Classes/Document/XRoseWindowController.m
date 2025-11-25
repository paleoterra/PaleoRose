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

#import "XRoseWindowController.h"
#import "XRPropertyInspector.h"
#import "XRoseDocument.h"
#import "XRGeometryPropertyInspector.h"
#import "FStatisticController.h"
#import "XRGeometryController.h"
#import "XRTableAddColumnController.h"
#import "XRCalculateAzimuthController.h"
#import "math.h"
#import "XRExportGraphicAccessory.h"
#import <PaleoRose-Swift.h>
#import "XRoseView.h"

@interface XRoseWindowController()
@property (nonatomic) FStatisticController *theSheetController;
@property (nonatomic) XRTableAddColumnController *addColumnController;
@property (nonatomic) XRCalculateAzimuthController *azimuthController;
@property (nonatomic) TableListController *tableListController;
@property (nonatomic, weak) DocumentModel *documentModelBacking;
@end
@implementation XRoseWindowController
NSRect initialRect;
+(void)initialize
{
	NSRect screenFrame = [[NSScreen mainScreen] frame];
	NSSize windowSize = NSMakeSize(620.0,396.0);
	initialRect.size = windowSize;
	initialRect.origin.x = (screenFrame.size.width - windowSize.width)/2.0;
	initialRect.origin.y = (screenFrame.size.height - windowSize.height)/2.0;
}

-(XRRoseTableController *)tableController
{
	return (XRRoseTableController *)self.layersTableController;
}

// Custom getter and setter for documentModel to ensure proper initialization order
- (DocumentModel *)documentModel {
    return self.documentModelBacking;
}

- (void)setDocumentModel:(DocumentModel *)documentModel {
    self.documentModelBacking = documentModel;

    // If controllers have already been created in awakeFromNib, complete their setup now
    if (documentModel) {
        [self completeControllerSetupWithDocumentModel:documentModel];
    }
}

- (void)completeControllerSetupWithDocumentModel:(DocumentModel *)documentModel {
    XRGeometryController *geometryController = documentModel.geometryController;

    // Update data sources for controllers
    if (self.tableListController) {
        [self.tableListController setDataSource:documentModel];
    }

    if (self.layersTableController) {
        [self.layersTableController setDataSource:documentModel];
        [self.layersTableController setGeometryController:geometryController];
    }

    // Set the back-reference in geometryController
    geometryController.layersTableController = self.layersTableController;

    // Set the rosePlotController reference in XRoseView
    XRoseView *roseView = (XRoseView *)_roseView;
    roseView.rosePlotController = geometryController;
    NSLog(@"XRoseWindowController: Set rosePlotController, view frame = %@", NSStringFromRect([roseView frame]));

    // If the view already has a non-zero frame, trigger geometry update now
    // Otherwise, it will be updated when setFrame: is called during window display
    if (!NSIsEmptyRect([roseView frame]) && [roseView frame].size.width > 0 && [roseView frame].size.height > 0) {
        NSLog(@"XRoseWindowController: Calling computeDrawingFrames immediately (frame is valid)");
        [roseView computeDrawingFrames];
    } else {
        NSLog(@"XRoseWindowController: NOT calling computeDrawingFrames (frame is empty/invalid)");
    }
}


-(void)awakeFromNib
{
    // Guard against multiple awakeFromNib calls on the SAME instance
    if (self.layersTableController != nil) {
        return;
    }

    // Create controllers - they will be configured when documentModel is set
    self.tableListController = [[TableListController alloc] initWithDataSource:nil];
    self.tableListController.tableView = self->_tableNameTable;

    self.layersTableController = [[LayersTableController alloc] initWithDataSource:nil geometryController:nil];
    self.layersTableController.tableView = (NSTableView *)_roseTableView;
    self.layersTableController.roseView = (NSView *)_roseView;
    self.layersTableController.windowController = self;

    // Set the controller references in XRoseView
    XRoseView *roseView = (XRoseView *)_roseView;
    roseView.roseTableController = self.layersTableController;

    // If documentModel was already set before awakeFromNib (unlikely), complete setup now
    if (self.documentModel) {
        [self completeControllerSetupWithDocumentModel:self.documentModel];
        // Set rosePlotController after documentModel is set
        roseView.rosePlotController = self.documentModel.geometryController;
    }

	NSToolbar *roseToolbar = [[NSToolbar alloc] initWithIdentifier:@"RoseToolbar"];
	[roseToolbar setDelegate:self];
	[[self window] setToolbar:roseToolbar];
	[roseToolbar setAutosavesConfiguration:YES];
	[roseToolbar setAllowsUserCustomization:YES];
	[[self document] configureDocument];
	if([[[NSDocumentController sharedDocumentController] documents] count] == 1)
	{
		//NSLog(@"displaying initial window");
		NSRect frame = [[self window] frame];
		//NSLog(NSStringFromRect(frame));
		frame.origin = initialRect.origin;
		[[self window] setFrame:frame display:YES];

		//NSLog(NSStringFromRect(initialRect));
	}

	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(splitViewDidResize:) name:NSViewFrameDidChangeNotification object:_windowSplitView];
	[[self document] awakeFromNib];
}

//toolbar control

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
	return [NSArray arrayWithObjects:NSToolbarPrintItemIdentifier,
		@"XRGeometryInspector",
		@"XRInspector",
		@"XRAddDataLayer",
		@"XRDeleteLayer",
		@"XRAddVectorLayer",
		@"XRAddTextLayer",
		
		nil];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
	return [NSArray arrayWithObjects:NSToolbarSeparatorItemIdentifier,
		NSToolbarSpaceItemIdentifier,
		NSToolbarFlexibleSpaceItemIdentifier,
		NSToolbarCustomizeToolbarItemIdentifier,
		NSToolbarPrintItemIdentifier,
		NSToolbarShowColorsItemIdentifier,
		NSToolbarShowFontsItemIdentifier,
		@"XRAddDataLayer",
		@"XRInspector",
		@"XRAddCoreLayer",
		@"XRDeleteLayer",
		@"XRAddGridLayer",
		@"XRAddVectorLayer",
		@"XRGeometryInspector",
		@"XRAddTextLayer",
		nil];

}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
	NSToolbarItem *anItem = nil;
	if([itemIdentifier isEqualToString:@"XRAddDataLayer"])
	{
		anItem = [[NSToolbarItem alloc] initWithItemIdentifier:@"XRAddDataLayer"];
		[anItem setLabel:@"Add Data Layer"];
		[anItem setPaletteLabel:@"Add Data Layer"];
		[anItem setToolTip:@"Add Data Layer"];
		[anItem setTarget:[self document]];//this is okay.  Has to tell the document to load more data
		[anItem setAction:@selector(addDataLayer:)];
		[anItem setImage:[[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]]pathForImageResource:@"LayerDrawerImageAddLayer"]]];
			
	}
	else if([itemIdentifier isEqualToString:@"XRInspector"])
	{
		anItem = [[NSToolbarItem alloc] initWithItemIdentifier:@"XRInspector"];
		[anItem setLabel:@"Inspector"];
		[anItem setPaletteLabel:@"Inspector"];
		[anItem setToolTip:@"Inspector"];
		[anItem setTarget:[XRPropertyInspector defaultInspector]];//this is okay.  Has to tell the document to load more data
			[anItem setAction:@selector(toggleInspector:)];
			[anItem setImage:[[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]]pathForImageResource:@"infoicon"]]];
			
	}
	else if([itemIdentifier isEqualToString:@"XRAddCoreLayer"])
	{
		anItem = [[NSToolbarItem alloc] initWithItemIdentifier:@"XRAddCoreLayer"];
		[anItem setLabel:@"Add Core Layer"];
		[anItem setPaletteLabel:@"Add Core Layer"];
		[anItem setToolTip:@"Add Core Layer"];
		[anItem setTarget:self.layersTableController];//this is okay.  Has to tell the document to load more data
		[anItem setAction:@selector(addCoreLayer:)];
		[anItem setImage:[[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]]pathForImageResource:@"coreLayer"]]];
			
	}
	else if([itemIdentifier isEqualToString:@"XRDeleteLayer"])
	{
		anItem = [[NSToolbarItem alloc] initWithItemIdentifier:@"XRDeleteLayer"];
		[anItem setLabel:@"Delete Layer"];
		[anItem setPaletteLabel:@"Delete Layer"];
		[anItem setToolTip:@"Delete Layer"];
		[anItem setTarget:self.layersTableController];//this is okay.  Has to tell the document to load more data
			[anItem setAction:@selector(deleteLayers:)];
			[anItem setImage:[[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]]pathForImageResource:@"removeLayer"]]];
			
	}
	else if([itemIdentifier isEqualToString:@"XRAddGridLayer"])
	{
		anItem = [[NSToolbarItem alloc] initWithItemIdentifier:@"XRAddGridLayer"];
		[anItem setLabel:@"Add Grid Layer"];
		[anItem setPaletteLabel:@"Add Grid Layer"];
		[anItem setToolTip:@"Add Grid Layer"];
		[anItem setTarget:self.layersTableController];//this is okay.  Has to tell the document to load more data
			[anItem setAction:@selector(addGridLayer:)];
			[anItem setImage:[[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]]pathForImageResource:@"gridLayer"]]];
			
	}
	else if([itemIdentifier isEqualToString:@"XRAddTextLayer"])
	{
		anItem = [[NSToolbarItem alloc] initWithItemIdentifier:@"XRAddTextLayer"];
		[anItem setLabel:@"Add Text Layer"];
		[anItem setPaletteLabel:@"Add Text Layer"];
		[anItem setToolTip:@"Add Text Layer"];
		[anItem setTarget:self.layersTableController];//this is okay.  Has to tell the document to load more data
			[anItem setAction:@selector(addTextLayer:)];
			[anItem setImage:[[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]]pathForImageResource:@"textLayer"]]];
			
	}
	else if([itemIdentifier isEqualToString:@"XRAddVectorLayer"])
	{
		anItem = [[NSToolbarItem alloc] initWithItemIdentifier:@"XRAddVectorLayer"];
		[anItem setLabel:@"Add Vector Layer"];
		[anItem setPaletteLabel:@"Add Vector Layer"];
		[anItem setToolTip:@"Add Vector Layer"];
		[anItem setTarget:self.layersTableController];//this is okay.  Has to tell the document to load more data
			[anItem setAction:@selector(displaySheetForVStatLayer:)];
			[anItem setImage:[[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]]pathForImageResource:@"vectorLayer"]]];
			
	}
	else if([itemIdentifier isEqualToString:@"XRGeometryInspector"])
	{
		anItem = [[NSToolbarItem alloc] initWithItemIdentifier:@"XRGeometryInspector"];
		[anItem setLabel:@"Geometry Inspector"];
		[anItem setPaletteLabel:@"Geometry Inspector"];
		[anItem setToolTip:@"Geometry Inspector"];
		[anItem setTarget:[XRGeometryPropertyInspector defaultGeometryInspector]];//this is okay.  Has to tell the document to load more data
		[anItem setAction:@selector(toggleInspector:)];
		[anItem setImage:[[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]]pathForImageResource:@"geometryInspector"]]];
			
	}
	return anItem;
}

-(void)copyPDFToPasteboard
{
	[_roseView copyPDFToPasteboard];
}

-(void)copyTIFFToPasteboard
{
	[_roseView copyTIFFToPasteboard];
}

-(NSView *)mainView
{
	return _roseView;
}

-(XRGeometryController *)geometryController
{
	return self.documentModel.geometryController;
}


-(void)windowDidBecomeMain:(NSNotification *)notification
{
	//NSLog(@"windowDidBecomeMain");
	[self.layersTableController displaySelectedLayerInInspector];
	[[XRGeometryPropertyInspector defaultGeometryInspector] displayInfoForObject:[self geometryController]];
}

-(void)addCoreLayer:(id)sender
{
	[self.layersTableController addCoreLayer:sender];
	//[[[self document] undoManager] registerUndoWithTarget:_roseTableController selector:@selector(deleteLayer:) object:sender];
	//[[[self document] undoManager] setActionName:@"Add Core Layer"];
}

-(void)addGridLayer:(id)sender
{
	[self.layersTableController addGridLayer:sender];
	//[[[self document] undoManager] registerUndoWithTarget:_roseTableController selector:@selector(deleteLayer:) object:sender];
	//[[[self document] undoManager] setActionName:@"Add Grid Layer"];
}

-(void)addVectorLayer:(id)sender
{
	[self.layersTableController displaySheetForVStatLayer:sender];
	//[[[self document] undoManager] registerUndoWithTarget:_roseTableController selector:@selector(deleteLayer:) object:sender];
	//[[[self document] undoManager] setActionName:@"Add Vector Layer"];
}

-(void)addTextLayer:(id)sender
{
	[self.layersTableController addTextLayer:sender];
	//[[[self document] undoManager] registerUndoWithTarget:_roseTableController selector:@selector(deleteLayer:) object:sender];
	//[[[self document] undoManager] setActionName:@"Add Text Layer"];
}

-(void)deleteLayers:(id)sender
{
	[self.layersTableController deleteLayers:sender];
	[[self document] updateChangeCount:NSChangeDone];
}

-(void)toggleInspector:(id)sender
{
	[[XRPropertyInspector defaultInspector] toggleInspector:sender];
}

-(void)toggleGeometryInspector:(id)sender
{
	[[XRGeometryPropertyInspector defaultGeometryInspector] toggleInspector:sender]; 
}

-(IBAction)generateFTestReport:(id)sender
{
	self.theSheetController = [[FStatisticController alloc] init];
	[self.theSheetController setLayerNames:[self.layersTableController dataLayerNames]];
	//NSLog(@"set layers sheet");
    [self.window beginSheet:[self.theSheetController window] completionHandler:^(NSModalResponse returnCode) {
        if(returnCode == NSModalResponseOK)
        {

            __block NSString *resultString = [(XRoseDocument *)[self document] FTestStatisticsForSetNames:[self->_theSheetController selectedItems] biDirectional:[self->_theSheetController isBiDir]];
            NSSavePanel *sp = [NSSavePanel savePanel];
            [sp setAllowedFileTypes:@[@"txt"]];
            [sp setNameFieldLabel:@"F-Stat Report"];
            [sp beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
                if(result == NSModalResponseOK)
                {
                    NSString *path = [[sp URL] path];
                    if([[NSFileManager defaultManager] fileExistsAtPath:path])
                        [[NSFileManager defaultManager]  removeItemAtPath:path error:nil];
                    [[NSFileManager defaultManager] createFileAtPath:path contents:[resultString dataUsingEncoding:NSASCIIStringEncoding] attributes:nil];

                    [[NSWorkspace sharedWorkspace] openFile:path withApplication:@"TextEdit"];
                }
            }];
        }
        self.theSheetController = nil;
    }];
}

-(void)windowWillClose:(NSNotification *)aNotification
{
	//NSLog(@"window will close");
	if([[self window] isMainWindow])
		[[XRGeometryPropertyInspector defaultGeometryInspector] displayInfoForObject:nil];
}


- (IBAction)addLayerAction:(id)sender
{
	[[self document] addDataLayer:sender];
}
- (IBAction)deleteLayerAction:(id)sender
{
	[self deleteLayers:sender];
}

- (IBAction)importTableAction:(id)sender
{
	[[self document] importTable:sender];
}



-(void)setTableList:(NSMutableArray *)aList
{
	tableList = aList;
}

-(void)importerCompleted:(NSNotification *)aNotification
{
    [self.documentModel readFromStoreWithCompletion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self document] discoverTables];
            [self updateTable];
        });
    }];


}

-(void)updateTable
{
	//NSLog(@"updatetable");
	
	[_tableNameTable reloadData];

}

-(IBAction)tableAddColumn:(id)sender
{
	//this method should work on selected table items.  otherwise, does nothing.
	self.addColumnController = [[XRTableAddColumnController alloc] init];
    [[self window]
     beginSheet:[self.addColumnController window]
     completionHandler:^(NSModalResponse returnCode) {
        if(returnCode == NSModalResponseOK)
        {
            //alter table "table name" add COLUMNNAME DEFINITION
            NSError *error;
            NSString *table = [self->tableList objectAtIndex: [self->_tableNameTable selectedRow]];
            NSString *columnDefinition = [self.addColumnController columnDefinition];
            [self.documentModel addWithTable:table column:columnDefinition error:&error];
            if(error != nil) {
                NSLog(@"Error: %@",error.localizedDescription);
            }
        }
        self.addColumnController = nil;
    }];
}

-(IBAction)deleteTableAction:(id)sender
{
    NSError *error;
	//deleting a table should also delete all layers and datasets that make use of it.
	NSString *tableToDelete = [tableList objectAtIndex:[_tableNameTable selectedRow]];

    [self.documentModel deleteWithTable:tableToDelete error:&error];
    if(error != nil) {
        NSLog(@"%@", error.localizedDescription);
    }

	//Table is now deleted.  We must now delete all dependent layers and datasets
	[self.layersTableController deleteLayersForTableName:tableToDelete];
	[[self document] discoverTables];
	[self updateTable];
}

-(IBAction)tablePerformCalculation:(id)sender
{
	if([[sender title] isEqualToString:@"Azimuth from Vectors"])
		[self performAzimuthFromVector];
}

-(void)performAzimuthFromVector
{
	int index = (int)[_tableNameTable selectedRow];

	if(index == -1)
	{
		if([tableList count]<1)
			return;
		else
			index = 0;
	}
	
	self.azimuthController = [[XRCalculateAzimuthController alloc] initWithDocument:[self document] withItemSelectedAtIndex:index];
    [[self window]
     beginSheet:[self.azimuthController window]
     completionHandler:^(NSModalResponse returnCode) {
        if(returnCode == NSModalResponseOK)
        {
            NSDictionary *results = [self.azimuthController resultDictionary];

            sqlite3 *db = [[self document] documentInMemoryStore];
            sqlite3_stmt *stmt;
            const char *pzTail;
            char *errorMsg;
            int error,valueCount;
            long long *indexes;
            double *finalValues;
            int currentIndex=0;
            NSString *command0 = [NSString stringWithFormat:@"SELECT count(*) FROM \"%@\"",[results objectForKey:@"table"]] ;
            //NSLog(command0);
            error = sqlite3_prepare(db,[command0 UTF8String],-1,&stmt,&pzTail);
            valueCount = -1;
            if(error!=SQLITE_OK)
                NSLog(@"Error 600: %s",(const char *)sqlite3_errmsg(db));
            while(sqlite3_step(stmt)==SQLITE_ROW)
            {
                valueCount = (int)sqlite3_column_int(stmt,0);
            }
            sqlite3_finalize(stmt);
            stmt = NULL;
            indexes = (long long *)malloc(sizeof(long long)*valueCount);
            finalValues = (double *)malloc(sizeof(double)*valueCount);
            NSString *command1 = [NSString stringWithFormat:@"SELECT _id, \"%@\", \"%@\" FROM \"%@\"",[results objectForKey:@"xVector"],[results objectForKey:@"yVector"],[results objectForKey:@"table"]] ;
            error = sqlite3_prepare(db,[command1 UTF8String],-1,&stmt,&pzTail);
            if(error!=SQLITE_OK)
                NSLog(@"Error: %s",(char *)sqlite3_errmsg(db));
            while(sqlite3_step(stmt)==SQLITE_ROW)
            {

                int columIndex;
                int columCount = sqlite3_column_count(stmt);
                long long int idNumber = -1;
                BOOL isNull = NO;
                char *nullTest;
                double xValue = 0.0;
                double yValue = 0.0;
                double hypot;
                double radians;
                double finalAngle;
                for(columIndex=0;columIndex<columCount;columIndex++)
                {
                    //now we have the sequence of columns.  Now string compare names
                    NSString *currentColumnName = [NSString stringWithUTF8String:(char *)sqlite3_column_name(stmt,columIndex)];

                    if([currentColumnName isEqualToString:@"_id"])
                    {
                        idNumber = (long long int)sqlite3_column_int64(stmt,columIndex);
                    }
                    else if([currentColumnName isEqualToString:[results objectForKey:@"xVector"]])
                    {
                        xValue  = (double)sqlite3_column_double(stmt,columIndex);
                        if(xValue == (float)0.0)
                        {
                            nullTest = (char *)sqlite3_column_text(stmt,columIndex);
                            if(!nullTest)
                                isNull = YES;
                        }
                    }
                    else if([currentColumnName isEqualToString:[results objectForKey:@"yVector"]])
                    {
                        yValue  = (double)sqlite3_column_double(stmt,columIndex);
                        if(yValue == (float)0.0)
                        {
                            nullTest = (char *)sqlite3_column_text(stmt,columIndex);
                            if(!nullTest)
                                isNull = YES;
                        }

                    }
                }
                if(!isNull)
                {
                    hypot = sqrt((xValue*xValue) + (yValue*yValue));
                    radians = asin(yValue/hypot);//compute angle;
                    if(xValue>=0.0)
                    {
                        finalAngle = 90 - ((180.0/M_PI)*radians);
                    }
                    else
                        finalAngle = 270 + ((180.0/M_PI)*radians);
                    indexes[currentIndex] = idNumber;
                    finalValues[currentIndex] = finalAngle;
                    currentIndex++;


                }

            }
            sqlite3_finalize(stmt);
            error = sqlite3_exec(db,"BEGIN",NULL,NULL,&errorMsg);
            if(error!=SQLITE_OK)
                NSLog(@"Error: %s",errorMsg);
            for(int i=0;i<currentIndex;i++)
            {
                NSString *command2 = [NSString stringWithFormat:@"UPDATE \"%@\" SET \"%@\"=\'%f\' WHERE _id=%lld",[results objectForKey:@"table"],[results objectForKey:@"target"],finalValues[i],indexes[i]];
                //NSLog(command2);
                error = sqlite3_exec(db,[command2 UTF8String],NULL,NULL,&errorMsg);
                if(error!=SQLITE_OK)
                    NSLog(@"Error: %s",errorMsg);

            }
            sqlite3_exec(db,"COMMIT",NULL,NULL,&errorMsg);
            free(finalValues);
            free(indexes);
        }
        self.azimuthController = nil;
    }];
}

-(IBAction)copyPDFImage:(id)sender
{
    [self copyPDFToPasteboard];
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
    if([self.documentModel fileURL])
        baseName = [[[self.documentModel fileURL] path ]stringByDeletingPathExtension];
    else
    {
        baseName = NSHomeDirectory();
        baseName = [baseName stringByAppendingPathComponent:[self.window title]];
    }
    [sp setDirectoryURL:[NSURL fileURLWithPath:[baseName stringByDeletingLastPathComponent]]];
    [sp beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if(result == NSModalResponseOK)
        {
            NSData *targetData;
            if((targetData = [(XRoseView *)[self mainView] imageDataForType:[[sp URL] pathExtension]]))
            {
                [[NSFileManager defaultManager] createFileAtPath:[[sp URL] path] contents:targetData attributes:nil];
            }
        }
    }];
}

-(IBAction)generateStatisticsReport:(id)sender
{
    NSSavePanel *sp = [NSSavePanel savePanel];
    NSURL *currentURL = [self.documentModel fileURL];
    __block NSString *basename = [[currentURL path ] lastPathComponent];
    if(!basename)
        basename = [self.window title];
    [sp setAllowedFileTypes:@[@"txt"]];
    [sp setDirectoryURL:[currentURL URLByDeletingLastPathComponent]];
    [sp beginSheetModalForWindow: self.window completionHandler:^(NSInteger result) {
        if(result == NSModalResponseOK)
        {
            NSMutableString *theString = [[NSMutableString alloc] init];
            [theString appendFormat:@"XRose STATISTICS REPORT FOR FILE: %@\n%@\n\n\n" ,currentURL ,[[NSDate date] descriptionWithLocale:nil]];
            //now append general geometry issues
            [theString appendFormat:@"Geometry:\n\tSector Count: %i\n\tSector Size (degrees): %f\n\n",[(XRGeometryController *)self.geometryController  sectorCount],[(XRGeometryController *)self.geometryController  sectorSize]];
            //have table controller append info
            [theString appendString:[self.layersTableController generateStatisticsString]];
            if([[NSFileManager defaultManager] fileExistsAtPath:[[sp URL] path]])
                [[NSFileManager defaultManager] removeItemAtPath:[[sp URL] path] error:nil];
            [[NSFileManager defaultManager] createFileAtPath:[[sp URL] path] contents:[theString dataUsingEncoding:NSASCIIStringEncoding] attributes:nil];
        }
    }];
}

@end

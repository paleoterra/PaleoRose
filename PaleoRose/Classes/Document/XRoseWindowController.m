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
#import "XRExportGraphicAccessory.h"
#import <PaleoRose-Swift.h>
#import "XRoseView.h"
#import "XRDataSet.h"
#import "XRStatistic.h"
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

@interface XRoseWindowController()
@property (nonatomic) FStatisticController *theSheetController;
@property (nonatomic) TableListController *tableListController;
@property (nonatomic, weak) id<DocumentModelProtocol> documentModelBacking;
@property (nonatomic) NSObject *currentSheetController;
@property (nonatomic) TableImportCoordinator *currentImportCoordinator;
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
- (id<DocumentModelProtocol>)documentModel {
    return self.documentModelBacking;
}

- (void)setDocumentModel:(id<DocumentModelProtocol>)documentModel {
    self.documentModelBacking = documentModel;

    // If controllers have already been created in awakeFromNib, complete their setup now
    if (documentModel) {
        [self completeControllerSetupWithDocumentModel:documentModel];
    }
}

- (void)completeControllerSetupWithDocumentModel:(id<DocumentModelProtocol>)documentModel {
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

    // Set window size and position
    NSRect frame = [[self window] frame];
    NSSize windowSize = [self.documentModel windowSize];
    if (!CGSizeEqualToSize(windowSize, CGSizeZero)) {
        frame.size = windowSize;
        [[self window] setFrame:frame display:YES];
    }

    [self.layersTableController createGridLayerIfNeeded];
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
	return [NSArray arrayWithObjects:
		NSToolbarSpaceItemIdentifier,
		NSToolbarFlexibleSpaceItemIdentifier,
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
		[anItem setTarget:self];
		[anItem setAction:@selector(addLayerAction:)];
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

            __block NSString *resultString = [self FTestStatisticsForSetNames:[self->_theSheetController selectedItems] biDirectional:[self->_theSheetController isBiDir]];
            NSSavePanel *sp = [NSSavePanel savePanel];
            [sp setAllowedContentTypes:@[UTTypePlainText]];
            [sp setNameFieldLabel:@"F-Stat Report"];
            [sp beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
                if(result == NSModalResponseOK)
                {
                    NSString *path = [[sp URL] path];
                    if([[NSFileManager defaultManager] fileExistsAtPath:path])
                        [[NSFileManager defaultManager]  removeItemAtPath:path error:nil];
                    [[NSFileManager defaultManager] createFileAtPath:path contents:[resultString dataUsingEncoding:NSASCIIStringEncoding] attributes:nil];
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

- (IBAction)addLayerAction:(id)sender {
    [self loadDataSet];
}

-(void)loadDataSet
{
    DatasetCreationSheet *controller = [[DatasetCreationSheet alloc] initWithTableArray:[self.documentModel dataTableNames]
                                                                         columnProvider:self.documentModel];
    self.currentSheetController = controller;
    [[self window]
     beginSheet:[controller window]
     completionHandler:^(NSModalResponse returnCode) {
        if(returnCode == NSModalResponseOK)
        {
            NSError *createError = nil;
            XRDataSet *aSet = [self.documentModel createDataSetWithTableName:[controller selectedTable]
                                                                  columnName:[controller selectedColumn]
                                                                        name:[controller selectedName]
                                                                       error:&createError];
            if(aSet && !createError)
            {
                [self.layersTableController addDataLayerFor:aSet];
                [self.document updateChangeCount:NSChangeDone];
            }
            else if(createError)
            {
                NSLog(@"Failed to create dataset: %@", [createError localizedDescription]);
            }
        }
        self.currentSheetController = nil;
    }];
}

- (IBAction)deleteLayerAction:(id)sender
{
	[self deleteLayers:sender];
}

- (IBAction)importTableAction:(id)sender
{
	[[self document] importTable:sender];
}

-(void)importTable:(id)sender
{
    NSOpenPanel *op = [NSOpenPanel openPanel];
    [op setAllowsMultipleSelection:NO];
    [op setAllowedContentTypes:@[UTTypePlainText, [UTType typeWithFilenameExtension:@"xrose"]]];
    [op beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
            NSURL *url = [op URL];
            if (!url) { return; }
            [op close];
            self.currentImportCoordinator = [[TableImportCoordinator alloc]
                initWithDocumentModel:self.documentModel
                window:[self window]];
            [self.currentImportCoordinator beginImportFromURL:url completionHandler:^(NSError *error) {
                if (error) { [self presentError:error]; }
                self.currentImportCoordinator = nil;
            }];
        }
    }];
}

-(IBAction)deleteTableAction:(id)sender
{
    NSArray *tableList = [self.documentModel dataTableNames];
    NSInteger selectedRow = [_tableNameTable selectedRow];
    if (selectedRow < 0 || selectedRow >= (NSInteger)[tableList count]) { return; }
    NSError *error;
	NSString *tableToDelete = [tableList objectAtIndex:selectedRow];

    [self.documentModel deleteWithTable:tableToDelete error:&error];
    if(error != nil) {
        NSLog(@"%@", error.localizedDescription);
    }

	//Table is now deleted.  We must now delete all dependent layers and datasets
	[self.layersTableController deleteLayersForTableName:tableToDelete];
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
    [sp setAllowedContentTypes:@[
        UTTypePDF,
        UTTypeTIFF,
        UTTypeJPEG
    ]];

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
    [sp setAllowedContentTypes:@[UTTypePlainText]];
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

-(NSString *)FTestStatisticsForSetNames:(NSArray *)setNames biDirectional:(BOOL)isBiDir
{
    XRDataSet *tempSet1 = [[self documentModel] dataSetWithName:[setNames objectAtIndex:0]];
    XRDataSet *tempSet2 = [[self documentModel] dataSetWithName:[setNames objectAtIndex:1]];
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

@end

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
#import "XRStatistic.h"
#import "PaleoRose-Swift.h"
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#import <os/activity.h>


@interface XRoseDocument() <DatasetColumnProvider>

@property (readwrite) BOOL didLoad;

@property (nonatomic) TableImportCoordinator *currentImportCoordinator;
@property (nonatomic) NSObject *currentSheetController;

@property (readwrite) DocumentModel* documentModel;
@property (weak, nonatomic) XRoseWindowController *mainWindowController;
@end

@implementation XRoseDocument

#pragma mark - Creating a Document Object

- (id)init
{
    self = [super init];
    if (self) {
        _documentModel = [[DocumentModel alloc] initInMemoryStore:[[InMemoryStore alloc] init] document:self];
        _didLoad = NO;
	}
    return self;
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
    [self.documentModel saveGeometryAndReturnError:&error];
    if (error != nil) {
        NSLog(@"Cannot store geometry: %@", [error localizedDescription]);
    }
    [self.documentModel setWindowSize:[self.mainWindowController window].frame.size error:&error];
    if (error != nil) {
        *outError = error;
        return NO;
    }
    [self.documentModel saveLayersAndReturnError:&error];
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
            NSError *createError = nil;
            XRDataSet *aSet = [self.documentModel createDataSetWithTableName:[controller selectedTable]
                                                                  columnName:[controller selectedColumn]
                                                                        name:[controller selectedName]
                                                                       error:&createError];
            if(aSet && !createError)
            {
                [self.mainWindowController.layersTableController addDataLayerFor:aSet];
                [self updateChangeCount:NSChangeDone];
            }
            else if(createError)
            {
                NSLog(@"Failed to create dataset: %@", [createError localizedDescription]);
            }
        }
        self.currentSheetController = nil;
    }];
}

#pragma mark Importing Data

-(void)importTable:(id)sender
{
    NSOpenPanel *op = [NSOpenPanel openPanel];
    [op setAllowsMultipleSelection:NO];
    [op setAllowedContentTypes:@[UTTypePlainText, [UTType typeWithFilenameExtension:@"xrose"]]];
    [op beginSheetModalForWindow:[self.mainWindowController window] completionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
            NSURL *url = [op URL];
            if (!url) { return; }
            [op close];
            self.currentImportCoordinator = [[TableImportCoordinator alloc]
                initWithDocumentModel:self.documentModel
                window:[[[self windowControllers] firstObject] window]];
            [self.currentImportCoordinator beginImportFromURL:url completionHandler:^(NSError *error) {
                if (error) { [self presentError:error]; }
                self.currentImportCoordinator = nil;
            }];
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

#pragma mark DatasetColumnProvider Protocol

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

- (NSArray<NSString *> * _Nonnull)numericColumnsForTable:(NSString * _Nonnull)tableName {
    NSArray *columns = [self retrieveNonTextColumnNamesFromTable:tableName];
    return columns ?: @[];
}

@end

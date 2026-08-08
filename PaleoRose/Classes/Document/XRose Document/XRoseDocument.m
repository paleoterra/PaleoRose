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

@interface XRoseDocument()

@property (readwrite) DocumentModel* documentModel;
@property (weak, nonatomic) XRoseWindowController *mainWindowController;
@end

@implementation XRoseDocument

#pragma mark - Creating a Document Object

- (id)init {
    self = [super init];
    if (self) {
        _documentModel = [[DocumentModel alloc] initInMemoryStore:[[InMemoryStore alloc] init] undoManager: self.undoManager];
	}
    return self;
}

#pragma mark - Reading the Document's Content

-(BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError * _Nullable __autoreleasing *)outError {
    if([typeName isEqualToString:@"XRose"])
    {
        NSError *error = nil;
        [self.documentModel openFile:url error:&error];
        if (error) {
            NSLog(@"%@", error.localizedDescription);
            return NO;
        }
        [self.documentModel setUrl:url];
        return YES;
    }
    return NO;
}

#pragma mark - Writing the Document's Content
-(BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError * _Nullable __autoreleasing *)outError {
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
    [self.documentModel setUrl:url];
    return YES;
}

-(void)makeWindowControllers {
    XRoseWindowController *aController = [[XRoseWindowController alloc] initWithWindowNibName:@"XRoseDocument"];
    [self addWindowController:aController];
    _mainWindowController = aController;
    _mainWindowController.documentModel = self.documentModel;
}

- (void)printDocument:(id)sender {
    [[NSPrintOperation printOperationWithView:[self.mainWindowController mainView] printInfo:[self printInfo]] runOperation];
}

- (NSError *)willPresentError:(NSError *)anError {
    //NSLog(@"will present error");
    return anError;
}

- (BOOL)presentError:(NSError *)error {
    if([super respondsToSelector:@selector(presentError:)])
        return [super presentError:error];
    else
        return NO;
}

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

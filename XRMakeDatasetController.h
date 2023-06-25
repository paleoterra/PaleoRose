//
// MIT License
//
// Copyright (c) 2006 to present Thomas L. Moore.
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
#import "sqlite3.h"

@interface XRMakeDatasetController : NSWindowController
{
    IBOutlet id columnsPop;
    IBOutlet id tablesPop;
	 IBOutlet id layerNameField;
	IBOutlet id  predicateSource;
	IBOutlet id predicateTableColumnsPop;
	IBOutlet id errorTextField;
	IBOutlet id placeholderView;
	IBOutlet id advancedSelectView;
	IBOutlet id advancedViewSwitch;
	IBOutlet id createButton;
	IBOutlet id validateButton;
	IBOutlet id operatorPopup;

	NSArray *_tables;
	NSMutableArray *_columns;
	NSMutableArray *_selectColumns;
	NSString *_path;
	NSRect placeholderOriginalRect;
	NSRect windowOriginalRect;
    sqlite3 *inMemoryStore;
}

-(id)initWithTableArray:(NSArray *)tables inMemoryDocument:(sqlite3 *)db;
-(NSString *)selectedTable;
-(NSString *)selectedColumn;
-(NSString *)selectedName;
- (IBAction)cancel:(id)sender;
- (IBAction)create:(id)sender;
- (IBAction)selectColumns:(id)sender;
- (IBAction)showAdvancedSelect:(id)sender;
- (IBAction)addPopupText:(id)sender;
- (IBAction)validatePredicate:(id)sender;
-(void)setValid:(BOOL)isValid;
-(NSString *)predicate;
@end

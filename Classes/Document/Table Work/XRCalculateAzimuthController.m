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

#import "XRCalculateAzimuthController.h"
#import "XRoseDocument.h"
@implementation XRCalculateAzimuthController

-(id)initWithDocument:(XRoseDocument *)aDocument withItemSelectedAtIndex:(int)index
{
	if (!(self = [super init])) return nil;
	if(self)
	{

		
		initialSelectedIndex = index;
		theDocument = aDocument; //weak link

        [[NSBundle mainBundle] loadNibNamed:@"XRCalculateAzimuthSheet"
                         owner:self
               topLevelObjects:nil];
	}
	return self;
}

-(void)dealloc
{
	
	return;
}
-(void)awakeFromNib
{

	theTables = [theDocument tableList];

	[tableNamePop removeAllItems];

	[tableNamePop addItemsWithTitles:theTables];

	[tableNamePop selectItemAtIndex:initialSelectedIndex];

	//okay, now we have to populate according to the selected item.
	[self populateSelectedColumns:self];

}
	
- (IBAction)execute:(id)sender
{
    [NSApp endSheet:window returnCode:NSModalResponseOK];
}

- (IBAction)cancel:(id)sender
{
    [NSApp endSheet:window returnCode:NSModalResponseCancel];
}

-(IBAction)populateSelectedColumns:(id)sender
{
	NSArray *populateItems = [theDocument retrieveNonTextColumnNamesFromTable:[tableNamePop titleOfSelectedItem]];
	[xVectorPop removeAllItems];
	[xVectorPop addItemsWithTitles:populateItems];                                                                   
	[yVectorPop removeAllItems];
	[yVectorPop addItemsWithTitles:populateItems];                          	
	[targetPop removeAllItems];
	[targetPop         addItemsWithTitles:populateItems];
}

-(NSDictionary *)resultDictionary
{
	NSDictionary *aDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[tableNamePop titleOfSelectedItem],[xVectorPop titleOfSelectedItem],[yVectorPop titleOfSelectedItem],[targetPop titleOfSelectedItem],nil]
													  forKeys:[NSArray arrayWithObjects:@"table",@"xVector",@"yVector",@"target",nil]];
	return aDict;
}

-(NSWindow *)window
{
	return window;
}

@end

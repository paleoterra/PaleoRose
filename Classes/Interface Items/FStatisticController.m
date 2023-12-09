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
#import "FStatisticController.h"

@implementation FStatisticController

-(id)init
{
	self = [super initWithWindowNibName:@"FStatisticSheet"];
	return self;
}


-(void)awakeFromNib
{
	[self populateLayers];
}
- (IBAction)calculateSheet:(id)sender
{
    [NSApp endSheet:[self window] returnCode:NSModalResponseOK];
}

- (IBAction)cancelSheet:(id)sender
{
    [NSApp endSheet:[self window] returnCode:NSModalResponseCancel];
}

-(void)setLayerNames:(NSArray *)nameList
{
	theArray = nameList;
	[self populateLayers];
}

-(NSArray *)selectedItems
{
	return [NSArray arrayWithObjects:[layerName1 titleOfSelectedItem],[layerName2 titleOfSelectedItem],nil];
}

-(BOOL)isBiDir
{
    if([biDirSwitch state] == NSControlStateValueOn)
		return YES;
	else
		return NO;
}

-(void)populateLayers
{
	[layerName1 removeAllItems];
	[layerName2 removeAllItems];
	if([theArray count] < 1)
	{
		[executeButton setEnabled:NO];
		[layerName1 addItemWithTitle:@"No Data Available"];
		[layerName2 addItemWithTitle:@"No Data Available"];
		
	}
	else 
	{
		[layerName1 addItemsWithTitles:theArray];
		[layerName2 addItemsWithTitles:theArray];
		[layerName1 selectItemAtIndex:0];
		if([theArray count] == 1)
		{
			[layerName1 selectItemAtIndex:0];
		}
		else
			[layerName1 selectItemAtIndex:1];
		
	}
	
}
@end

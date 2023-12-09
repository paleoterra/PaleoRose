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

#import "XRAppendDialogController.h"
#import "XRDataSet.h"

@implementation XRAppendDialogController

-(id)init
{
	if (!(self = [super initWithWindowNibName:@"AppendDialog" owner:self])) return nil;

	return self;
}
- (IBAction)append:(id)sender
{
	[NSApp endSheet:[self window] returnCode:2];
}

- (IBAction)cancel:(id)sender
{
	[NSApp endSheet:[self window] returnCode:0];
}

- (IBAction)new:(id)sender
{
	[NSApp endSheet:[self window] returnCode:1];
}

-(NSPopUpButton *)thePopup
{
	return _popup;
}

-(NSString *)titleOfSelectedSet
{
	return [_popup titleOfSelectedItem];
}

-(void)dataSetArray:(NSArray *)aArray
{
	titlesArray = aArray;
}

-(void)awakeFromNib
{
	NSEnumerator *anEnum = [titlesArray objectEnumerator];
	XRDataSet *theSet;

	[_popup removeAllItems];
	while(theSet = [anEnum nextObject])
	{
		[_popup addItemWithTitle:[theSet name]];
	}
}
@end

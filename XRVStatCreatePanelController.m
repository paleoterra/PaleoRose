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

#import "XRVStatCreatePanelController.h"

@implementation XRVStatCreatePanelController

-(id)initWithArray:(NSArray *)anArray
{
	if (!(self = [super initWithWindowNibName:@"XRVStatPanel" owner:self])) return nil;
	_names = anArray;
	return self;
}


- (IBAction)cancel:(id)sender
{
    [NSApp endSheet:[self window] returnCode:NSModalResponseCancel];
}

- (IBAction)createLayer:(id)sender
{
    [NSApp endSheet:[self window] returnCode:NSModalResponseOK];
}

-(NSString *)selectedName
{

	return [layerChoicesPopup titleOfSelectedItem];
}

-(void)awakeFromNib
{
	[layerChoicesPopup removeAllItems];
	[layerChoicesPopup addItemsWithTitles:_names];
}
@end

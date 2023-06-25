//
//  XRExportGraphicAccessory.m
//  XRose
//
//  Created by Tom Moore on Fri Apr 16 2004.
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

#import "XRExportGraphicAccessory.h"


@implementation XRExportGraphicAccessory

+(id)exportGraphicAccessoryView
{
	NSRect aRect = NSMakeRect(0.0,0.0,272.0,60.0);
	XRExportGraphicAccessory *theView = [[XRExportGraphicAccessory alloc] initWithFrame:aRect];
	return theView;
}


- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		thePopup = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(65,16,190,26)];
		[thePopup removeAllItems];
		[thePopup addItemsWithTitles:[NSArray arrayWithObjects:@"PDF",@"JPEG",@"TIFF",nil]];
		[thePopup setTarget:self];
		[thePopup setAction:@selector(selectionDidChange:)];
		[self addSubview:thePopup];
		
		theTitle = [[NSTextField alloc] initWithFrame:NSMakeRect(4,22,59,17)];
		[theTitle setDrawsBackground:NO];
		[theTitle setBezeled:NO];
		[theTitle setStringValue:@"Format:"];
		[self addSubview:theTitle];
    }
    return self;
}




-(void)setDelegate:(id)aDelegate
{
	delegate = aDelegate;
}

-(void)selectionDidChange:(id)sender
{
	if([delegate respondsToSelector:@selector(setRequiredFileType:)])
	{

		
		if([[sender titleOfSelectedItem] isEqualToString:@"PDF"])
            [delegate setAllowedFileTypes:@[@"pdf"]];
		else if([[sender titleOfSelectedItem] isEqualToString:@"JPEG"])
            [delegate setAllowedFileTypes:@[@"jpg"]];
		else if([[sender titleOfSelectedItem] isEqualToString:@"TIFF"])
            [delegate setAllowedFileTypes:@[@"tif"]];
	}
}

-(NSString *)pathExtension
{
	return [thePopup titleOfSelectedItem];
}
@end

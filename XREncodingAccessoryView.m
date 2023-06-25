//
//  XREncodingAccessoryView.m
//  XRose
//
//  Created by Tom Moore on Tue Jan 06 2004.
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

#import "XREncodingAccessoryView.h"


@implementation XREncodingAccessoryView

-(id)init
{
	NSRect aRect = NSMakeRect(0.0,0.0,314.0,55.0);
	if (!(self = [self initWithFrame:aRect])) return nil;
	return self;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		unsigned int mask;
		NSRect aRect = NSMakeRect(17.0,20.0,114.0,19.0);
		//set mask for self
		mask = 0  | NSViewWidthSizable | NSViewHeightSizable;
		[self setAutoresizingMask:mask];
		NSTextField *textField = [[NSTextField alloc] initWithFrame:aRect];
		[textField setStringValue:@"Encoding:"];
		mask = 0  | NSViewMaxYMargin | NSViewMinYMargin;
		[textField setAutoresizingMask:mask];
		[textField setEditable:NO];
		[textField setDrawsBackground:NO];
		[textField setBordered:NO];
		[self addSubview:textField];
	
		
		
		aRect = NSMakeRect(89.0,16.0,214.0,26.0);
		thePopup = [[NSPopUpButton alloc] initWithFrame:aRect];
		[self setEncodingList];
		mask = 0  | NSViewMaxYMargin | NSViewMinYMargin | NSViewWidthSizable;
		[thePopup setAutoresizingMask:mask];
		[self addSubview:thePopup]; 
    }
    return self;
}


- (void)drawRect:(NSRect)rect {
    // Drawing code here.
	[super drawRect:rect];
}

-(void)setEncodingList
{
	NSArray *encodings = [NSArray arrayWithObjects:@"ASCII String",
		@"MacOS Roman",
		@"NextStep",
		@"UTF-8",
		@"ISO Latin 1",
		@"ISO Latin 2",
		@"Unicode",
		@"Windows CP1251",
		@"Windows CP1252",
		@"Windows CP1253",
		@"Windows CP1254",
		@"Windows CP1250",
		nil];
	[thePopup addItemsWithTitles:encodings];
}

-(NSStringEncoding)selectedEncoding
{
	NSUInteger i;
	i = [thePopup indexOfSelectedItem];
	switch(i)
	{
		case 0:
			return NSASCIIStringEncoding;
			break;
		case 1:
			return NSMacOSRomanStringEncoding;
			break;
		case 2:
			return NSNEXTSTEPStringEncoding;
			break;
		case 3:
			return NSUTF8StringEncoding;
			break;
		case 4:
			return NSISOLatin1StringEncoding;
			break;
		case 5:
			return NSISOLatin2StringEncoding;
			break;
		case 6:
			return NSUnicodeStringEncoding;
			break;
		case 7:
			return NSWindowsCP1251StringEncoding;
			break;
		case 8:
			return NSWindowsCP1252StringEncoding;
			break;
		case 9:
			return NSWindowsCP1253StringEncoding;
			break;
		case 10:
			return NSWindowsCP1254StringEncoding;
			break;
		case 11:
			return NSWindowsCP1250StringEncoding;
			break;
		default:
			return NSISO2022JPStringEncoding;
			break;
	}
}


@end

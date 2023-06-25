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

#import "XRTableImporterXRose.h"

@implementation XRTableImporterXRose

-(id)init
{
	if (!(self = [super init])) return nil;
	if(self)
	{
		theArray = [[NSMutableArray alloc] init];
        [[NSBundle mainBundle] loadNibNamed:@"XRTableImporterXRoseSheet"
                         owner:self
               topLevelObjects:nil];
	}
	return self;
}


-(void)setTableNames:(NSArray *)theNames
{
	NSEnumerator *anEnum = [theNames objectEnumerator];
	NSString *aName;
	[theArray removeAllObjects];
	while(aName = [anEnum nextObject])
	{
        [theArray addObject:[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:NSControlStateValueOn],aName,nil]
											 forKeys:[NSArray arrayWithObjects:@"selection",@"table",nil]]];
	}
}

-(NSArray *)selectedTableNames
{
	NSEnumerator *anEnum = [theArray objectEnumerator];
	NSMutableDictionary *aDict;
	NSMutableArray *results = [[NSMutableArray alloc] init];
	while(aDict = [anEnum nextObject])
	{
        if([[aDict objectForKey:@"selection"] intValue]==NSControlStateValueOn)
			[results addObject:[aDict objectForKey:@"table"]];
	}
	return [NSArray arrayWithArray:results];
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return (int)[theArray count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	NSString *key = [aTableColumn identifier];
	return [[theArray objectAtIndex:rowIndex] objectForKey:key];
	
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	NSString *key = [aTableColumn identifier];
	[[theArray objectAtIndex:rowIndex] setObject:anObject forKey:key];
}

- (IBAction)cancel:(id)sender
{
    [NSApp endSheet:window returnCode:NSModalResponseCancel];
}

- (IBAction)import:(id)sender
{
    [NSApp endSheet:window returnCode:NSModalResponseOK];
}

-(NSWindow *)window
{
	return window;
}


@end

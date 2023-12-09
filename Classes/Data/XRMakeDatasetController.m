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

#import "XRMakeDatasetController.h"
#import "sqlite3.h"
@implementation XRMakeDatasetController

-(id)initWithTableArray:(NSArray *)tables inMemoryDocument:(sqlite3 *)db
{
	if (!(self = [super initWithWindowNibName:@"XRCreateDatasetSheet"])) return nil;
	_tables = tables;
	inMemoryStore = db;
	_columns = [[NSMutableArray alloc] init];
	_selectColumns  = [[NSMutableArray alloc] init];
	return self;
}

-(void)awakeFromNib
{
	[tablesPop removeAllItems];
	[tablesPop addItemsWithTitles:_tables];
	[self selectColumns:self];
	placeholderOriginalRect = [placeholderView frame];
	windowOriginalRect = [placeholderView frame];
	
	//[[[self window] contentView] addSubview:advancedSelectView];
	[advancedSelectView setHidden:YES];
	[self setValid:YES];
	[errorTextField setStringValue:@""];
}
- (IBAction)cancel:(id)sender
{
    [NSApp endSheet:[self window] returnCode:NSModalResponseCancel];
}

- (IBAction)create:(id)sender
{
    [NSApp endSheet:[self window] returnCode:NSModalResponseOK];
}

- (IBAction)selectColumns:(id)sender
{
	NSString *theSQL;
	sqlite3_stmt *stmt;
	const char *pzTail;
	int error;
	int count;
	//char *errorMsg;
	int type;

	theSQL = [NSString stringWithFormat:@"SELECT * FROM \"%@\" LIMIT 1",[tablesPop titleOfSelectedItem]];
	error = sqlite3_prepare(inMemoryStore,[theSQL UTF8String],-1,&stmt,&pzTail);
	[_columns removeAllObjects];
	[_selectColumns removeAllObjects];
	if(error == SQLITE_OK)
	{
	while(sqlite3_step(stmt)!=SQLITE_DONE)
	{
		count = sqlite3_column_count(stmt);
		for(int i=0;i<count;i++)
		{
		type = sqlite3_column_type(stmt,i);

		if((type==SQLITE_INTEGER)||(type==SQLITE_FLOAT))
		{
			[_columns addObject:[NSString stringWithUTF8String:(char *)sqlite3_column_name(stmt,i)]];
		}
		[_selectColumns addObject:[NSString stringWithUTF8String:(char *)sqlite3_column_name(stmt,i)]];
		}
	}
	}
	[columnsPop removeAllItems];
	[predicateTableColumnsPop removeAllItems];
	[columnsPop addItemsWithTitles:_columns];
	[predicateTableColumnsPop addItemsWithTitles:_selectColumns];
	
}

-(NSString *)selectedTable
{
	return [tablesPop titleOfSelectedItem];
}

-(NSString *)selectedColumn
{
	return [columnsPop titleOfSelectedItem];
}

-(NSString *)selectedName
{
	return [layerNameField stringValue];
}

- (IBAction)showAdvancedSelect:(id)sender
{
	NSSize difference = NSMakeSize([advancedSelectView frame].size.width-[placeholderView frame].size.width,[advancedSelectView frame].size.height-[placeholderView frame].size.height);
	
    if([sender state] == NSControlStateValueOn)
	{
		NSRect aFrame =[[self window] frame];
		aFrame.size.height += difference.height;
		aFrame.origin.y -= difference.height;
		[[self window] setFrame:aFrame display:YES animate:YES];
		NSRect pFrame = [placeholderView frame];
		aFrame = [advancedSelectView frame];
		aFrame.origin = pFrame.origin;
		aFrame.origin.y -=  difference.height;
		[advancedSelectView setFrame:aFrame];
		[advancedSelectView setHidden:NO];

	}
	else
	{
		[advancedSelectView setHidden:YES];
		NSRect aFrame =[[self window] frame];
		aFrame.origin.y += difference.height;
		aFrame.size.height -= difference.height;
		[[self window] setFrame:aFrame display:YES animate:YES];

	}
}

- (IBAction)addPopupText:(id)sender
{
	if(sender == predicateTableColumnsPop)
	{
		[predicateSource insertText:[NSString stringWithFormat:@" \"%@\" ", [sender titleOfSelectedItem]]];
	}
	else
	{
		[predicateSource insertText:[NSString stringWithFormat:@"%@", [sender titleOfSelectedItem]]];
	}
	
}

- (IBAction)validatePredicate:(id)sender
{

	NSString *theSQL;

	int error;

	char *errorMsg;

	//assemble new sql statement
	theSQL = [NSString stringWithFormat:@"SELECT count(*) FROM \"%@\" WHERE \"%@\">=0 AND \"%@\"<=360 AND %@",[tablesPop titleOfSelectedItem],[columnsPop titleOfSelectedItem],[columnsPop titleOfSelectedItem],[predicateSource string]];
	error = sqlite3_exec(inMemoryStore,[theSQL UTF8String],NULL,NULL,&errorMsg);
	if(error!=SQLITE_OK)
	{
		[errorTextField setStringValue:[NSString stringWithUTF8String:errorMsg]];
	}
	else
	{
		[errorTextField setStringValue:@""];
		[self setValid:YES];
	}
}

-(void)textDidChange:(NSNotification *)notification
{
	[self setValid:NO];
}

-(void)setValid:(BOOL)isValid
{
	if(isValid)
	{
		[validateButton setEnabled:NO];
		[createButton setEnabled:YES];
	}
	else
	{
		[validateButton setEnabled:YES];
		[createButton setEnabled:NO];
	}
}


-(NSString *)predicate
{
	if([predicateSource string])
	{
		if([[predicateSource string] length] > 0)
			return [predicateSource string];
		else
			return nil;
	}
	else
		return nil;
}
@end

//
//  PTFMXMLParser.m
//  XRose
//
//  Created by Tom Moore on 12/28/05.
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

#import "PTFMXMLParser.h"
#import "sqlite3.h"

@implementation PTFMXMLParser

-(id)initWithXMLAtPath:(NSString *)path
{
	if (!(self = [super init])) return nil;
	if(self)
	{
		NSURL *theURL = [NSURL fileURLWithPath:path];
		tableDefinition = [[NSMutableArray alloc] init];
		dataRows = [[NSMutableArray alloc] init];
		correctType = NO;
		theParser = [[NSXMLParser alloc] initWithContentsOfURL:theURL];
		[theParser setDelegate:self];
		isValid = [theParser parse];
		tableStep = 0;
		
	}
	return self;
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict 
{

	if([elementName isEqualToString:@"FMPXMLRESULT"])
		correctType = YES;
	else if([elementName isEqualToString:@"DATABASE"])
	{
		tableName = [attributeDict objectForKey:@"NAME"];
		//NSLog(@"Table Name: %@",tableName);
	}
	else if([elementName isEqualToString:@"FIELD"])
	{
		[tableDefinition addObject:attributeDict];
	}
	else if([elementName isEqualToString:@"ROW"])
	{
		currentRow = [[NSMutableArray alloc] init];
	}
	else if([elementName isEqualToString:@"COL"])
	{
		hasData = NO;
	}
	else if([elementName isEqualToString:@"DATA"])
	{
		hasData = YES;
		currentContents = [[NSMutableString alloc] init];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
{
	if([elementName isEqualToString:@"ROW"])
	{
		[dataRows addObject:[NSArray arrayWithArray:currentRow]];
		currentRow = nil;
	}
	else if([elementName isEqualToString:@"COL"])
	{
		if(!hasData)
			[currentRow addObject:[NSNull null]];
	}
	else if([elementName isEqualToString:@"DATA"])
	{
		[currentRow addObject:currentContents];
		currentContents = nil;
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{

	if(currentContents)
		[currentContents appendString:string];
}

-(BOOL)isCorrectType
{
	return correctType;
}

-(BOOL)isValid
{
	return isValid;
}

-(NSString *)sqliteTableSchema
{
	NSMutableString *theString = [[NSMutableString alloc] init];
	[theString appendFormat:@"CREATE TABLE \"%@\" (\n_id INTEGER PRIMARY KEY,\n",tableName];
	NSDictionary *aDict;
	for(int i=0;i<[tableDefinition count];i++)
	{
		aDict = [tableDefinition objectAtIndex:i];
		if(i == ([tableDefinition count] -1 )) 
			[theString appendFormat:@"%@ %@\n )",[aDict objectForKey:@"NAME"], [aDict objectForKey:@"TYPE"]];
		else
			[theString appendFormat:@"%@ %@, \n",[aDict objectForKey:@"NAME"], [aDict objectForKey:@"TYPE"]];
	}
	return theString;
}

-(void)stepTableName
{
	//This is designed to step the table name if table name already exists
	if(tableStep == 0)
	{
		NSString *oldName = tableName;
		tableName = [oldName stringByAppendingString:@"_1"];
		oldName = nil;
		tableStep++;
	}
	else
	{
		NSString *oldName = tableName;
		NSRange aRange,aIntersectRange,aStringRange;
		aStringRange.length = [oldName length];
		aStringRange.location = 0;
		aRange = [oldName rangeOfString:[NSString stringWithFormat:@"_%i",tableStep] options:NSBackwardsSearch];
		aIntersectRange = NSIntersectionRange(aStringRange,aRange);
		tableStep++;
		tableName = [[oldName substringWithRange:aIntersectRange] stringByAppendingFormat:@"_%i",tableStep];
		oldName = nil;
		tableStep++;
	}
	return;
}

-(int)rows
{
	return (int)[dataRows count];
}

-(NSString *)sqliteCommandForRow:(int)aRow
{
	NSMutableString *command = [[NSMutableString alloc] init];
	NSArray *rowArray = [dataRows objectAtIndex:aRow];
	[command appendString:[self assembleSQLITEInsertBase]];
	int count;
	count = (int)[rowArray count];
	[command appendString:@"VALUES ("];
	for(int i = 0;i<count;i++)
	{
		if([[rowArray objectAtIndex:i] isKindOfClass:[NSNull class]])
			[command appendString:@"NULL"];
		else
			[command appendFormat:@"\"%@\"",[rowArray objectAtIndex:i]];
		if(i<(count-1))
			[command appendString:@","];
		else
			[command appendString:@")"];
	}
	return command;
}

-(NSString *)assembleSQLITEInsertBase
{
	NSMutableString *base = [[NSMutableString alloc] init];
	[base appendFormat:@"INSERT INTO \"%@\" (",tableName];

	for(int i=0;i<[tableDefinition count];i++)
	{
		if(i==([tableDefinition count] - 1))
			[base appendFormat:@"%@) ",[[tableDefinition objectAtIndex:i] objectForKey:@"NAME"]];
		else
			[base appendFormat:@"%@,",[[tableDefinition objectAtIndex:i] objectForKey:@"NAME"]];
	}
	return base;
}

-(BOOL)writeToSQLITE:(sqlite3 *)db withError:(NSError **)anError
{
	int error;
	int count;
	sqlite3_stmt *stmt;
	const char *pzTail;
	char *errorMsg;

	//make sure table name is unique
	count = -1;//set it up for failure on a while statement
	
	while(count!=0)
	{
		NSString *aString = [NSString stringWithFormat:@"select count(*) from sqlite_master where tbl_name=\"%@\"",tableName];
		sqlite3_prepare(db,[aString UTF8String],-1,&stmt,&pzTail);
		while(sqlite3_step(stmt)==SQLITE_ROW)
		{
			count = sqlite3_column_int(stmt,0);
		}
		sqlite3_finalize(stmt);
		if(count>0)
			[self stepTableName];
	}
	
	
	error = sqlite3_exec(db,"BEGIN",NULL,NULL,&errorMsg);
	if(error!=SQLITE_OK)
	{
        if(anError != NULL ) {
		*anError = [NSError errorWithDomain:@"SQLITE" code:error userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithUTF8String:(char *)sqlite3_errmsg(db)],nil]
																								forKeys:[NSArray arrayWithObjects:NSLocalizedDescriptionKey,nil]]];
                              }
		sqlite3_exec(db,"ROLLBACK",NULL,NULL,&errorMsg);
		return NO;
	}
	//now create table schema in db
	
	error = sqlite3_exec(db,[[self sqliteTableSchema] UTF8String],NULL,NULL,&errorMsg);
	//NSLog([self sqliteTableSchema]);
	if(error!=SQLITE_OK)
	{
        if(anError != NULL ){
            *anError = [NSError errorWithDomain:@"SQLITE" code:error userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithUTF8String:(char *)sqlite3_errmsg(db)],nil]
                                                                                                          forKeys:[NSArray arrayWithObjects:NSLocalizedDescriptionKey,nil]]];
        }
		
		sqlite3_exec(db,"ROLLBACK",NULL,NULL,&errorMsg);
		return NO;
	}
	
	//now insert rows
	for(int i=0;i<[self rows];i++)
	{
		error = sqlite3_exec(db,[[self sqliteCommandForRow:i] UTF8String],NULL,NULL,&errorMsg);
		if(error!=SQLITE_OK)
		{
            if(anError != NULL ) {
                *anError = [[NSError alloc] initWithDomain:@"SQLITE"
                                                      code:error
                                                  userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithUTF8String:(char *)sqlite3_errmsg(db)],nil]
                                                                                       forKeys:[NSArray arrayWithObjects:NSLocalizedDescriptionKey,nil]]];
            }
                sqlite3_exec(db,"ROLLBACK",NULL,NULL,&errorMsg);
			return NO;
		}
	}
	//commit changes
	
	error = sqlite3_exec(db,"COMMIT",NULL,NULL,&errorMsg);
	if(error!=SQLITE_OK)
	{
		if(anError != NULL ) {
		*anError = [NSError errorWithDomain:@"SQLITE" code:error userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithUTF8String:(char *)sqlite3_errmsg(db)],nil]
																									  forKeys:[NSArray arrayWithObjects:NSLocalizedDescriptionKey,nil]]];
        }
		sqlite3_exec(db,"ROLLBACK",NULL,NULL,&errorMsg);
		return NO;
	}
	
	return YES;
}
@end

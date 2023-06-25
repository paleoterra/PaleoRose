//
//  XRTableImporter.m
//  XRose
//
//  Created by Tom Moore on 12/13/05.
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

#import "XRTableImporter.h"
#import "XRTableImporterDelimiterController.h"
#import "XRoseDocument.h"
#import "sqlite3.h"
#import "PTFMXMLParser.h"
#import "XRTableImporterXRose.h"

@interface XRTableImporter()

@property (nonatomic) XRTableImporterDelimiterController *delimiterController;
@property (nonatomic) XRTableImporterXRose *theImporterController;
@end
@implementation XRTableImporter

//post notification when complete
-(void)importTableFromFile:(NSString *)source forDocument:(NSDocument *)aDocument
{

	sourcePath = source;
	targetDocument = aDocument;
	
	/* the assumption is made here that the document window currently has no sheet */
	if(([[sourcePath pathExtension] isEqualToString:@"txt"]) || ([[sourcePath pathExtension] isEqualToString:@"TXT"]))
	{
		[self importTextFromFile];
	}
	else if([[sourcePath pathExtension] isEqualToString:@"XRose"])
	{
		[self importFromXRoseDB];
	}
	else if(([[sourcePath pathExtension] isEqualToString:@"xml"]) || ([[sourcePath pathExtension] isEqualToString:@"XML"]))
	{
		[self importFromFMXML];
	}
	
}

-(void)clear
{
	sourcePath = nil;
	targetDocument = nil;
}

-(void)importTextFromFile
{
	self.delimiterController = [[XRTableImporterDelimiterController alloc] initWithPath:sourcePath];
    [[[[targetDocument windowControllers] objectAtIndex:0] window]
     beginSheet:[self.delimiterController window]
     completionHandler:^(NSModalResponse returnCode) {
        if(returnCode == NSModalResponseOK)
        {
            int columnCount = 0;
            int rowCount = 0;
            int k;
            NSMutableArray *columnTitles = [[NSMutableArray alloc] init];
            NSMutableArray *types = [[NSMutableArray alloc] init];
            NSCharacterSet *aSet = [NSCharacterSet letterCharacterSet];
            NSDictionary *aDict = [self.delimiterController results];
            NSMutableArray *theContents = [[NSMutableArray alloc] init];
            NSString *sourceString = [NSString stringWithContentsOfFile:self->sourcePath encoding:NSUTF8StringEncoding error:nil];
            //NSArray *theLines = [sourceString componentsSeparatedByString:@"\n"];//each line in file

            NSString *temp;

            NSArray *theLines = [sourceString componentsSeparatedByString:@"\n"];
            if([theLines count] == 1)
            {
                theLines = [sourceString componentsSeparatedByString:@"\r"];
            }
            if([theLines count] == 1)
            {
                theLines = [sourceString componentsSeparatedByString:@"\r"];
            }
            NSEnumerator *theEnum = [theLines objectEnumerator];
            //get each value in the line.
            while(temp = [theEnum nextObject])
            {
                [theContents addObject:[temp componentsSeparatedByString:@"\t"]];
            }
            //NSLog(@"column count %i",[theContents count]);
            /* at this point, we are ready to design the db. */
            for(int i=0;i<[theContents count];i++)
            {
                if(i==0)
                    columnCount = (int)[[theContents objectAtIndex:i] count];
                else
                    if([[theContents objectAtIndex:i] count] != columnCount)
                    {
                        [self->targetDocument presentError:[NSError errorWithDomain:@"com.paleoterra.xrose" code:-1 userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Text table has improper shape.",nil]
                                                                                                                                        forKeys:[NSArray arrayWithObjects:NSLocalizedDescriptionKey,nil]]]];
                    }
            }
            //now if we made it here, the next step is to determin column titles
            if([[aDict objectForKey:@"columnTitles"] intValue] == NSControlStateValueOn)
            {
                [columnTitles addObjectsFromArray:[theContents objectAtIndex:0]];
                [theContents removeObjectAtIndex:0];
            }
            else
            {
                for(int i=0;i<columnCount;i++)
                {
                    [columnTitles addObject:[NSString stringWithFormat:@"Column_%i",i+1]];
                }
            }

            //the next step is to determin column type, being a string or number.
            //I think as a rule I'll assign any ascii as TEXT and any number as NUMERIC
            rowCount = (int)[theContents count];

            //here, cycle through each column, cell, to determine affinity
            NSRange aRange;
            for(int i=0;i<columnCount;i++)
            {
                k = 0;//set to 1 if TEXT affinity
                for(int j=0;j<rowCount;j++)
                {
                    aRange = [[[theContents objectAtIndex:j] objectAtIndex:i] rangeOfCharacterFromSet:aSet];
                    if(aRange.location != NSNotFound)
                    {
                        k = 1;
                        j=rowCount;
                    }
                }
                if(k==0)
                    [types addObject:@"NUMERIC"];
                else
                    [types addObject:@"TEXT"];
            }

            //now, all the types are determined.  We can create the SQL command;
            NSMutableString *SQLCreateCommand = [[NSMutableString alloc] init];
            [SQLCreateCommand appendFormat:@"CREATE TABLE \"%@\" (\n",[aDict objectForKey:@"tableName"]];
            [SQLCreateCommand appendString:@"\t_id INTEGER PRIMARY KEY,\n"];
            for(int i=0;i<columnCount;i++)
            {
                if(i == columnCount -1)
                    [SQLCreateCommand appendFormat:@"\t\"%@\" %@\n",[columnTitles objectAtIndex:i],[types objectAtIndex:i]];

                else
                    [SQLCreateCommand appendFormat:@"\t\"%@\" %@,\n",[columnTitles objectAtIndex:i],[types objectAtIndex:i]];
            }
            [SQLCreateCommand appendString:@")"];
            //NSLog(SQLCreateCommand);

            //At this point, we can create the table and populate it.
            [self createTableWithSQL:SQLCreateCommand withTableArray:theContents table:[aDict objectForKey:@"tableName"] columnNames:columnTitles];
        }
        self.delimiterController = nil;
    }];
}


-(void)createTableWithSQL:(NSString *)sqlCreate withTableArray:(NSArray *)contents table:(NSString *)table columnNames:(NSArray *)names
{
	sqlite3 *db = [(XRoseDocument *)targetDocument documentInMemoryStore];
	int error;
	int columns, columnIndex, rows, rowIndex;
	char *errorMsg;
	NSMutableString *baseSQLString= [[NSMutableString alloc] init];

	//let's do this as a transaction rather than a single set of commands
	error = sqlite3_exec(db,"BEGIN",NULL,NULL,&errorMsg);
	//NSLog(@"BEGIN");
	if(error!=SQLITE_OK)
	{
		[targetDocument presentError:[NSError errorWithDomain:@"SQLITE" code:error userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithUTF8String:errorMsg],nil]			
																														forKeys:[NSArray arrayWithObjects:NSLocalizedDescriptionKey,nil]]]];

		sqlite3_exec(db,"ROLLBACK",NULL,NULL,&errorMsg);
		return;
	}
	
	
	
	error = sqlite3_exec(db,[sqlCreate UTF8String],NULL,NULL,&errorMsg);
	
	if(error!=SQLITE_OK)
	{
		[targetDocument presentError:[NSError errorWithDomain:@"SQLITE" code:error userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithUTF8String:errorMsg],nil]			
																														forKeys:[NSArray arrayWithObjects:NSLocalizedDescriptionKey,nil]]]];
		
		sqlite3_exec(db,"ROLLBACK",NULL,NULL,&errorMsg);
		return;
	}
	columns = (int)[[contents objectAtIndex:0] count];
	rows = (int)[contents count];
	[baseSQLString appendFormat:@"INSERT INTO \"%@\" (_id",table];
	for(columnIndex = 0;columnIndex<columns;columnIndex++)
	{
		[baseSQLString appendFormat:@",\"%@\"",[names objectAtIndex:columnIndex]];
	}
	[baseSQLString appendString:@") VALUES (NULL"];
	for(rowIndex=0;rowIndex<rows;rowIndex++)
	{
		NSMutableString *aString = [[NSMutableString alloc] init];
		[aString appendString:baseSQLString];
		for(columnIndex=0;columnIndex<columns;columnIndex++)
		{
			[aString appendFormat:@",\"%@\"",[[contents objectAtIndex:rowIndex] objectAtIndex:columnIndex]];
		}
		[aString appendString:@")"];
		error = sqlite3_exec(db,[aString UTF8String],NULL,NULL,&errorMsg);
		
		if(error!=SQLITE_OK)
		{
			[targetDocument presentError:[NSError errorWithDomain:@"SQLITE" code:error userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithUTF8String:errorMsg],nil]			
																															forKeys:[NSArray arrayWithObjects:NSLocalizedDescriptionKey,nil]]]];
			
			sqlite3_exec(db,"ROLLBACK",NULL,NULL,&errorMsg);
			return;
		}
	}
	error = sqlite3_exec(db,"COMMIT",NULL,NULL,&errorMsg);
	
	if(error!=SQLITE_OK)
	{
		[targetDocument presentError:[NSError errorWithDomain:@"SQLITE" code:error userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithUTF8String:errorMsg],nil]			
																														forKeys:[NSArray arrayWithObjects:NSLocalizedDescriptionKey,nil]]]];
		
		sqlite3_exec(db,"ROLLBACK",NULL,NULL,&errorMsg);
		return;
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:@"XRTableListChanged" object:nil];
}

-(void)importFromFMXML
{
	NSError *anError;
	
	PTFMXMLParser *theParser = [[PTFMXMLParser alloc] initWithXMLAtPath:sourcePath];
	if(([theParser isValid])&&([theParser isCorrectType]))
	{
		if(![theParser writeToSQLITE:[(XRoseDocument *)targetDocument documentInMemoryStore] withError:&anError])
			[targetDocument presentError:anError];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:@"XRTableListChanged" object:nil];
}

-(void)importFromXRoseDB
{
	sqlite3* db; //source xrose file
	int error;
	const char *pzTail;
	sqlite3_stmt *stmt;
	unichar leader = '_';
	NSMutableArray *anArray = [[NSMutableArray alloc] init];
	self.theImporterController = [[XRTableImporterXRose alloc] init];
	error = sqlite3_open([sourcePath UTF8String],&db);
	if(error!=SQLITE_OK)
	{
		[targetDocument presentError:[NSError errorWithDomain:@"SQLITE" code:error userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithUTF8String:(char *)sqlite3_errmsg(db)],nil]			
																														forKeys:[NSArray arrayWithObjects:NSLocalizedDescriptionKey,nil]]]];
		return;
	}
	error = sqlite3_prepare(db,"SELECT tbl_name FROM sqlite_master",-1,&stmt,&pzTail);
	if(error!=SQLITE_OK)
	{
		[targetDocument presentError:[NSError errorWithDomain:@"SQLITE" code:error userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithUTF8String:(char *)sqlite3_errmsg(db)],nil]			
																														forKeys:[NSArray arrayWithObjects:NSLocalizedDescriptionKey,nil]]]];
		return;
	}
	while(sqlite3_step(stmt)==SQLITE_ROW)
	{
		NSString *aString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt,0)];
		if([aString characterAtIndex:0] != leader)
			[anArray addObject:aString];
	}
	//this appears to work up to here.  next, we need to create the sheet, display it, and do a did end.
	[self.theImporterController setTableNames:anArray];
    [[[[targetDocument windowControllers] objectAtIndex:0] window]
     beginSheet:[self.theImporterController window]
     completionHandler:^(NSModalResponse returnCode) {
        NSArray *results = [self.theImporterController selectedTableNames];
        
        if((returnCode == NSModalResponseOK)&&([results count]>0))
        {
            //At this point, we have a list of table names we'd like to import.  So, we need to do the following:
            // 1. determine if table names exist
            //        a, if name exists, then rename with an extension
            // start transaction
            // import each table as needed.
            NSEnumerator *anEnum;
            NSDictionary *aDict;
            sqlite3 *db = [(XRoseDocument *)self->targetDocument documentInMemoryStore];
            sqlite3_stmt *stmt;
            const char *pzTail;
            char *errorMsg;
            int error;
            NSArray *theValidatedNames = [self validateNames:results];
            //okay, now we have the validated names and we can copy data from one file to another.


            error = sqlite3_exec(db,[[NSString stringWithFormat:@"ATTACH DATABASE \"%@\" AS source",self->sourcePath] UTF8String],NULL,NULL,&errorMsg);
            if(error!=SQLITE_OK)
            {
                [self->targetDocument presentError:[NSError errorWithDomain:@"SQLITE" code:error userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithUTF8String:errorMsg],nil]
                                                                                                                                forKeys:[NSArray arrayWithObjects:NSLocalizedDescriptionKey,nil]]]];
                return;
            }

            error = sqlite3_exec(db,"BEGIN",NULL,NULL,&errorMsg);
            if(error!=SQLITE_OK)
            {
                [self->targetDocument presentError:[NSError errorWithDomain:@"SQLITE" code:error userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithUTF8String:errorMsg],nil]
                                                                                                                                forKeys:[NSArray arrayWithObjects:NSLocalizedDescriptionKey,nil]]]];
                return;
            }
            //now we have both databases attached for copying purposes.
            //now, we need to create the schema for the new table

            anEnum = [theValidatedNames objectEnumerator];
            while(aDict = [anEnum nextObject])
            {
                NSString *schema;
                error = sqlite3_prepare(db,[[NSString stringWithFormat:@"SELECT \"sql\" FROM source.sqlite_master where tbl_name=\"%@\"",[aDict objectForKey:@"original"]] UTF8String],-1,&stmt,&pzTail);
                if(error!=SQLITE_OK)
                {
                    [self->targetDocument presentError:[NSError errorWithDomain:@"SQLITE" code:error userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithUTF8String:(char *)sqlite3_errmsg(db)],nil]
                                                                                                                                    forKeys:[NSArray arrayWithObjects:NSLocalizedDescriptionKey,nil]]]];
                    sqlite3_exec(db,"ROLLBACK",NULL,NULL,&errorMsg);
                    return;
                }
                while(sqlite3_step(stmt)==SQLITE_ROW)
                {
                    schema = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt,0)];
                }
                sqlite3_finalize(stmt);
                schema = [self processSchema:schema forNameResult:aDict];
                //now we have the corrected schema, now create the table
                error = sqlite3_exec(db,[schema UTF8String],NULL,NULL,&errorMsg);
                if(error!=SQLITE_OK)
                {
                    [self->targetDocument presentError:[NSError errorWithDomain:@"SQLITE" code:error userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithUTF8String:(char *)sqlite3_errmsg(db)],nil]
                                                                                                                                    forKeys:[NSArray arrayWithObjects:NSLocalizedDescriptionKey,nil]]]];
                    sqlite3_exec(db,"ROLLBACK",NULL,NULL,&errorMsg);
                    return;
                }
                //now the new table exists.  now copy data
                NSString *copyCommand = [self copyTableCommandForNameSet:aDict];
                error = sqlite3_exec(db,[copyCommand UTF8String],NULL,NULL,&errorMsg);
                if(error!=SQLITE_OK)
                {
                    [self->targetDocument presentError:[NSError errorWithDomain:@"SQLITE" code:error userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithUTF8String:(char *)sqlite3_errmsg(db)],nil]
                                                                                                                                    forKeys:[NSArray arrayWithObjects:NSLocalizedDescriptionKey,nil]]]];
                    sqlite3_exec(db,"ROLLBACK",NULL,NULL,&errorMsg);
                    return;
                }


            }
            error = sqlite3_exec(db,"COMMIT",NULL,NULL,&errorMsg);
            if(error!=SQLITE_OK)
            {
                [self->targetDocument presentError:[NSError errorWithDomain:@"SQLITE" code:error userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithUTF8String:errorMsg],nil]
                                                                                                                                forKeys:[NSArray arrayWithObjects:NSLocalizedDescriptionKey,nil]]]];
                return;
            }

        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"XRTableListChanged" object:nil];
        self.theImporterController = nil;
    }];
}

-(BOOL)isTableNameValid:(NSString *)tableName
{
	//Does the table name have a "_" character at the beginning.
	unichar theChar = '_';
	if([tableName characterAtIndex:0] == theChar)
		return NO;
	else
		return YES;
}

-(NSArray *)validateNames:(NSArray *)names
{
	NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    sqlite3 *db = [(XRoseDocument *)targetDocument documentInMemoryStore];
	sqlite3_stmt *stmt;
	const char *pzTail;
	NSEnumerator *anEnum = [names objectEnumerator];
	NSString *aName;

	while(aName = [anEnum nextObject])
	{
		
		NSMutableDictionary *aDict = [[NSMutableDictionary alloc] init];
		int result = -1;
		int step = 0;
		[aDict setObject:aName forKey:@"original"];
		[aDict setObject:[NSNumber numberWithBool:YES] forKey:@"isValid"];
		while(result !=  0)
		{
			sqlite3_prepare(db,[[NSString stringWithFormat:@"SELECT count(*) FROM sqlite_master WHERE tbl_name=\"%@\"",aName] UTF8String],-1,&stmt,&pzTail);
			while(sqlite3_step(stmt)==SQLITE_ROW)
				result = sqlite3_column_int(stmt,0);
			if(result >0)
			{
				step++;
				aName = [self renameTable:aName forStep:step];
				[aDict setObject:[NSNumber numberWithBool:NO] forKey:@"isValid"];
				[aDict setObject:aName forKey:@"alternate"];
			}
			sqlite3_finalize(stmt);
		}
		[resultArray addObject:aDict];
	}

	return [NSArray arrayWithArray:resultArray];
}

-(NSString *)renameTable:(NSString *)oldName forStep:(int)stepValue
{
	NSString *newName;
	int lastStep;
	if(stepValue == 1)
		newName = [oldName stringByAppendingString:@"_1"];
	else
	{
		lastStep = stepValue - 1;
		NSRange aRange,aIntersectRange,aStringRange;
		aStringRange.length = [oldName length];
		aStringRange.location = 0;
		aRange = [oldName rangeOfString:[NSString stringWithFormat:@"_%i",lastStep] options:NSBackwardsSearch];
		aIntersectRange = NSIntersectionRange(aStringRange,aRange);
		
		newName = [[oldName substringWithRange:aIntersectRange] stringByAppendingFormat:@"_%i",stepValue];
	}
	return newName;
}

-(NSString *)processSchema:(NSString *)aString forNameResult:(NSDictionary *)aDict
{
	
	NSString *create = @"CREATE TABLE main.";
	NSScanner *aScanner = [NSScanner scannerWithString:aString];
	NSString *tempString,*finalString;
	
	//scan away the create command
	[aScanner scanUpToString:@"(" intoString:nil];
	[aScanner scanUpToString:@")" intoString:&tempString];
	
	
	if([[aDict objectForKey:@"isValid"] boolValue] == YES)
	{
		finalString = [NSString stringWithFormat:@"%@%@ %@)",create,[aDict objectForKey:@"original"],tempString];
	}
	else
	{
		finalString = [NSString stringWithFormat:@"%@%@ %@)",create,[aDict objectForKey:@"alternate"],tempString];
	}
	
	return finalString;
}

-(NSString *)copyTableCommandForNameSet:(NSDictionary *)aDict
{
	
	NSMutableString *command = [[NSMutableString alloc] init];
	
	[command appendString:@"INSERT INTO main."];
	if([[aDict objectForKey:@"isValid"] boolValue] == YES)
		[command appendString:[aDict objectForKey:@"original"]];
	else
		[command appendString:[aDict objectForKey:@"alternate"]];
	[command appendFormat:@" SELECT * FROM source.%@",[aDict objectForKey:@"original"]];
	return command;
}

@end

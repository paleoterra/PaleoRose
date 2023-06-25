//
//  PTFMXMLParser.h
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

#import <Cocoa/Cocoa.h>
#import "sqlite3.h"

@interface PTFMXMLParser : NSObject <NSXMLParserDelegate>{
	NSMutableArray *tableDefinition;
	NSMutableArray *dataRows;
	BOOL isValid;
	BOOL correctType;
	NSXMLParser *theParser;
	NSMutableArray *currentRow;
	NSMutableString *currentContents;
	BOOL hasData;
	NSString *tableName;
	int tableStep;
}
-(id)initWithXMLAtPath:(NSString *)path;
-(int)rows;
-(BOOL)isCorrectType;//check if the XML is a supported format
-(BOOL)isValid;
-(void)stepTableName;//add a number to the end of the table name for individuality
//SQLITE CODE
-(NSString *)sqliteTableSchema;
-(NSString *)sqliteCommandForRow:(int)aRow;
-(NSString *)assembleSQLITEInsertBase;
-(BOOL)writeToSQLITE:(sqlite3 *)db withError:(NSError **)anError;
@end

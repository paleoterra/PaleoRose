//
//  LITMXMLParser.m
//  LITMAppKit
//
//  Created by Tom Moore on Mon Nov 10 2003.
//
// MIT License
//
// Copyright (c) 2003 to present Thomas L. Moore.
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

#import "LITMXMLParser.h"
#import "LITMXMLTree.h"


@implementation LITMXMLParser

+(id)xmlParserForData:(NSData *)theData
{
    LITMXMLParser * theParser = [[LITMXMLParser alloc] init];
    NSXMLParser *baseParser = [[NSXMLParser alloc] initWithData:theData];
    [baseParser setDelegate:theParser];
    [baseParser parse];
    return theParser;
}

-(id)init
{
    if(self = [super init])
    {
        theRootArray = [[NSMutableArray alloc] init];
        return self;
    }
    return nil;
}


-(NSArray *)theTreeArray
{
    return [NSArray arrayWithArray:theRootArray];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    LITMXMLTree *aTree = [[LITMXMLTree alloc] init];
    
    [aTree setElementName:elementName];
    [aTree setElementType:@"element"];
    [aTree setAttributesDictionary:attributeDict];
    [aTree setAttributeOrder:[NSMutableArray arrayWithArray:[attributeDict allKeys]]];
    [theRootArray addObject:aTree];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    LITMXMLTree *aTree;
    int indexOfTree;
    int count;
    int i;
    indexOfTree = -1;
    count = (int)[theRootArray count];
    for(i=(count -1);i>-1;i--)
    {
        if([[[theRootArray objectAtIndex:i]elementName] isEqualToString:elementName])
        {
            indexOfTree = i;
            i = -1;
        }
    }
    
    aTree = [theRootArray objectAtIndex:indexOfTree];
    [aTree setIsClosed:YES];
    for(i=(indexOfTree + 1);i<count;i++)
    {
        [aTree addChild:[theRootArray objectAtIndex:i]];
    }
    for(i=(count - 1);i>indexOfTree;i--)
    {
        [theRootArray removeObjectAtIndex:i];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    //this assumes that characters are only added to the last element.  If the last element is closed, or has children, don't add
    LITMXMLTree * aTree = (LITMXMLTree *)[theRootArray lastObject];
    if((![aTree isClosed])&&([aTree childCount]==0))
    {
    [(LITMXMLTree *)[theRootArray lastObject] appendContentsString:string];
    //NSLog(string);
    }
    //}
}

- (void)parser:(NSXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data
{
    //NSLog(@"foundProcessingInstructionWithTarget unimplemented");
    //NSLog(target);
    //NSLog([data description]);
}

/*- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
    NSLog(@"foundCDATA unimplemented");
}*/

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    //NSLog([parseError localizedDescription]);
}




/*- (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString
{
    NSLog(@"found whitespace");
    //allow whitespace to be ignored
}*/

/*- (NSData *)parser:(NSXMLParser *)parser resolveExternalEntityName:(NSString *)name systemID:(NSString *)systemID
{
    
    NSLog(@"found resolveExternalEntityName %@",name);
}*/

/*- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment
{
    NSLog(@"found foundComment %@",comment);
}*/

/*- (void)parser:(NSXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI
{
    NSLog(@"found didStartMappingPrefix %@",prefix);
}*/

/*- (void)parser:(NSXMLParser *)parser didEndMappingPrefix:(NSString *)prefix
{
    NSLog(@"found didEndMappingPrefix %@",prefix);
}*/

//dtd declarations
/*- (void)parser:(NSXMLParser *)parser foundAttributeDeclarationWithName:(NSString *)attributeName forElement:(NSString*)elementName type:(NSString *)type defaultValue:(NSString *)defaultValue
{
    NSLog(@"found foundAttributeDeclarationWithName");
} */

/*- (void)parser:(NSXMLParser *)parser foundExternalEntityDeclarationWithName:(NSString *)name publicID:(NSString*)publicID systemID:(NSString *)systemID
{
     NSLog(@"found foundExternalEntityDeclarationWithName");
}*/


/*- (void)parser:(NSXMLParser *)parser foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model
{
    NSLog(@"found foundElementDeclarationWithName");
}*/

/*- (void)parser:(NSXMLParser *)parser foundNotationDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID
{
    NSLog(@"found foundNotationDeclarationWithName");
}*/

/*- (void)parser:(NSXMLParser *)parser foundInternalEntityDeclarationWithName:(NSString *)name value:(NSString *)value
{
    NSLog(@"found foundInternalEntityDeclarationWithName");
}*/

/*- (void)parser:(NSXMLParser *)parser foundUnparsedEntityDeclarationWithName:(NSString *)name publicID:(NSString*)publicID systemID:(NSString *)systemID notationName:(NSString *)notationName
{
    NSLog(@"found foundUnparsedEntityDeclarationWithName");
}*/
@end

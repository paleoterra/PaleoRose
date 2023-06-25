//
//  XRFileParser.m
//  XRose
//
//  Created by Tom Moore on Mon Mar 08 2004.
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

#import "XRFileParser.h"
#import "XRFileParser1.h"
#import "LITMXMLTree.h"
#import "LITMXMLParser.h"

@implementation XRFileParser

+(NSData *)currentVersionXMLFromDictionary:(NSDictionary *)aDict
{
	XRFileParser1 *theParser = [[XRFileParser1 alloc] init];
	NSDictionary *tempDict;
	NSData *xmlData;
	LITMXMLTree *theTree;
	NSMutableString *baseString = [[NSMutableString alloc] init];
	[baseString appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"];
	
	theTree = [theParser documentBaseTree];
	//NSLog(@"generate geometrysettings");
	if((tempDict = [aDict objectForKey:@"geometrySettings"]))
		[theTree addChild:[theParser treeForGeometryControllerDictionary:tempDict]];
	//NSLog(@"generate table");
	if((tempDict = [aDict objectForKey:@"layersSettings"]))
		[theTree addChild:[theParser treeForTableControllerDictionary:tempDict]];

	//NSLog(@"generate string");
	[baseString appendString:[theTree xml]];
	xmlData = [baseString dataUsingEncoding:NSUTF8StringEncoding];

	return xmlData;
}

+(NSData *)XMLFromDictionary:(NSDictionary *)aDict forVersion:(NSString *)version
{
	
	return nil;
}


+(NSDictionary *)fileFromXMLData:(NSData *)theData
{
	LITMXMLTree *theTree = [[[LITMXMLParser xmlParserForData:theData] theTreeArray] objectAtIndex:0];
	if([[[theTree attributesDictionary] objectForKey:@"VERSION"] isEqualToString:@"1.0"])
	{
		
		XRFileParser1 *theParser = [[XRFileParser1 alloc] init];
		return [theParser dictionaryForDocumentTree:theTree];
	}
	else
		return nil;
}

-(LITMXMLTree *)documentBaseTree
{
	return nil;
}

-(NSDictionary *)dictionaryForDocumentTree:(LITMXMLTree *)theTree
{
	return nil;
}

-(LITMXMLTree *)treeForDataSetDictionary:(NSDictionary *)theDict
{
	return nil;
}

-(NSDictionary *)dictionarForDataSetXMLTree:(LITMXMLTree *)theTree
{
	return nil;
}


-(LITMXMLTree *)treeForGeometryControllerDictionary:(NSDictionary *)theDict
{
	return nil;
}

-(NSDictionary *)dictionarForGeometryControllerXMLTree:(LITMXMLTree *)theTree
{
	return nil;
}




-(LITMXMLTree *)treeForTableControllerDictionary:(NSDictionary *)theDict
{
	return nil;
}

-(NSDictionary *)dictionarForTableControllerXMLTree:(LITMXMLTree *)theTree
{
	return nil;
}


-(LITMXMLTree *)treeForLayerDictionary:(NSDictionary *)theDict
{
	return nil;
}

-(NSDictionary *)dictionarForLayerXMLTree:(LITMXMLTree *)theTree
{
	return nil;
}


-(LITMXMLTree *)treeForDataLayerDictionary:(NSDictionary *)theDict
{
	return nil;
}

-(NSDictionary *)dictionarForDataLayerXMLTree:(LITMXMLTree *)theTree
{
	return nil;
}


-(LITMXMLTree *)treeForGridLayerDictionary:(NSDictionary *)theDict
{
	return nil;
}

-(NSDictionary *)dictionarForGridLayerXMLTree:(LITMXMLTree *)theTree
{
	return nil;
}


-(LITMXMLTree *)treeForCoreLayerDictionary:(NSDictionary *)theDict
{
	return nil;
}

-(NSDictionary *)dictionarForCoreLayerXMLTree:(LITMXMLTree *)theTree
{
	return nil;
}


-(LITMXMLTree *)treeForGraphicDictionary:(NSDictionary *)theDict
{
	return nil;
}

-(NSDictionary *)dictionarForGraphicXMLTree:(LITMXMLTree *)theTree
{
	return nil;
}


-(LITMXMLTree *)treeForGraphicCircleDictionary:(NSDictionary *)theDict
{
	return nil;
}

-(NSDictionary *)dictionarForGraphicCircleXMLTree:(LITMXMLTree *)theTree
{
	return nil;
}


-(LITMXMLTree *)treeForGraphicCircleLabelDictionary:(NSDictionary *)theDict
{
	return nil;
}

-(NSDictionary *)dictionarForGraphicCircleLabelXMLTree:(LITMXMLTree *)theTree
{
	return nil;
}


-(LITMXMLTree *)treeForGraphicLineDictionary:(NSDictionary *)theDict
{
	return nil;
}

-(NSDictionary *)dictionarForGraphicLineXMLTree:(LITMXMLTree *)theTree
{
	return nil;
}


-(LITMXMLTree *)treeForGraphicKiteDictionary:(NSDictionary *)theDict
{
	return nil;
}

-(NSDictionary *)dictionarForGraphicKiteXMLTree:(LITMXMLTree *)theTree
{
	return nil;
}


-(LITMXMLTree *)treeForGraphicPetalDictionary:(NSDictionary *)theDict
{
	return nil;
}

-(NSDictionary *)dictionarForGraphicPetalXMLTree:(LITMXMLTree *)theTree
{
	return nil;
}


-(LITMXMLTree *)treeForGraphicDotDictionary:(NSDictionary *)theDict
{
	return nil;
}

-(NSDictionary *)dictionarForGraphicDotXMLTree:(LITMXMLTree *)theTree
{
	return nil;
}


-(LITMXMLTree *)treeForGraphicHistogramDictionary:(NSDictionary *)theDict
{
	return nil;
}

-(NSDictionary *)dictionarForGraphicHistogramXMLTree:(LITMXMLTree *)theTree
{
	return nil;
}


-(LITMXMLTree *)treeForGraphicDotDeviationDictionary:(NSDictionary *)theDict
{
	return nil;
}

-(NSDictionary *)dictionarForGraphicDotDeviationXMLTree:(LITMXMLTree *)theTree
{
	return nil;
}
@end

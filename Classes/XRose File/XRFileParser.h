//
//  XRFileParser.h
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


#import <Foundation/Foundation.h>

@class LITMXMLTree;
@interface XRFileParser : NSObject {

}

+(NSData *)currentVersionXMLFromDictionary:(NSDictionary *)aDict;
+(NSData *)XMLFromDictionary:(NSDictionary *)aDict forVersion:(NSString *)version;

+(NSDictionary *)fileFromXMLData:(NSData *)theData;

-(LITMXMLTree *)documentBaseTree;
-(NSDictionary *)dictionaryForDocumentTree:(LITMXMLTree *)theTree;
-(LITMXMLTree *)treeForDataSetDictionary:(NSDictionary *)theDict;
-(NSDictionary *)dictionarForDataSetXMLTree:(LITMXMLTree *)theTree;

-(LITMXMLTree *)treeForGeometryControllerDictionary:(NSDictionary *)theDict;
-(NSDictionary *)dictionarForGeometryControllerXMLTree:(LITMXMLTree *)theTree;

//-(LITMXMLTree *)treeForGeometryControllerDictionary:(NSDictionary *)theDict;
//-(NSDictionary *)dictionarForGeometryControllerXMLTree:(LITMXMLTree *)theTree;

-(LITMXMLTree *)treeForTableControllerDictionary:(NSDictionary *)theDict;
-(NSDictionary *)dictionarForTableControllerXMLTree:(LITMXMLTree *)theTree;

-(LITMXMLTree *)treeForLayerDictionary:(NSDictionary *)theDict;
-(NSDictionary *)dictionarForLayerXMLTree:(LITMXMLTree *)theTree;

-(LITMXMLTree *)treeForDataLayerDictionary:(NSDictionary *)theDict;
-(NSDictionary *)dictionarForDataLayerXMLTree:(LITMXMLTree *)theTree;

-(LITMXMLTree *)treeForGridLayerDictionary:(NSDictionary *)theDict;
-(NSDictionary *)dictionarForGridLayerXMLTree:(LITMXMLTree *)theTree;

-(LITMXMLTree *)treeForCoreLayerDictionary:(NSDictionary *)theDict;
-(NSDictionary *)dictionarForCoreLayerXMLTree:(LITMXMLTree *)theTree;

-(LITMXMLTree *)treeForGraphicDictionary:(NSDictionary *)theDict;
-(NSDictionary *)dictionarForGraphicXMLTree:(LITMXMLTree *)theTree;

-(LITMXMLTree *)treeForGraphicCircleDictionary:(NSDictionary *)theDict;
-(NSDictionary *)dictionarForGraphicCircleXMLTree:(LITMXMLTree *)theTree;

-(LITMXMLTree *)treeForGraphicCircleLabelDictionary:(NSDictionary *)theDict;
-(NSDictionary *)dictionarForGraphicCircleLabelXMLTree:(LITMXMLTree *)theTree;

-(LITMXMLTree *)treeForGraphicLineDictionary:(NSDictionary *)theDict;
-(NSDictionary *)dictionarForGraphicLineXMLTree:(LITMXMLTree *)theTree;

-(LITMXMLTree *)treeForGraphicKiteDictionary:(NSDictionary *)theDict;
-(NSDictionary *)dictionarForGraphicKiteXMLTree:(LITMXMLTree *)theTree;

-(LITMXMLTree *)treeForGraphicPetalDictionary:(NSDictionary *)theDict;
-(NSDictionary *)dictionarForGraphicPetalXMLTree:(LITMXMLTree *)theTree;

-(LITMXMLTree *)treeForGraphicDotDictionary:(NSDictionary *)theDict;
-(NSDictionary *)dictionarForGraphicDotXMLTree:(LITMXMLTree *)theTree;

-(LITMXMLTree *)treeForGraphicHistogramDictionary:(NSDictionary *)theDict;
-(NSDictionary *)dictionarForGraphicHistogramXMLTree:(LITMXMLTree *)theTree;

-(LITMXMLTree *)treeForGraphicDotDeviationDictionary:(NSDictionary *)theDict;
-(NSDictionary *)dictionarForGraphicDotDeviationXMLTree:(LITMXMLTree *)theTree;


@end

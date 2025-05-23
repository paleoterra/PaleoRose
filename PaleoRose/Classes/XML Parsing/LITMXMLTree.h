//
//  LITMXMLTree.h
//  LITMAppKit
//
//  Created by Tom Moore on Sun Nov 09 2003.
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

#import <Foundation/Foundation.h>
#import "LITMXMLNodeProtocol.h"

@interface LITMXMLTree : NSObject <LITMXMLNodeProtocol> {
    //basic tree management
//    LITMXMLTree *_nodeParent;
//    NSMutableArray *_nodeChildren;
//    NSString *elementContents;//accessor done
//    NSString *elementName;//accessor done
//    NSMutableDictionary *elementAttributes;//accessor done
//    NSMutableArray *attributeOrder;//accessor done
//    NSString *elementType;
    int _level;
//    BOOL isClosed;
}

@property (strong) LITMXMLTree *_nodeParent;
@property (strong) NSMutableArray *_nodeChildren;
@property (strong) NSString *elementContents;
@property (strong) NSString *elementName;
@property (strong) NSMutableDictionary *elementAttributes;
@property (strong) NSMutableArray *attributeOrder;
@property (strong) NSString *elementType;
@property (assign) BOOL isClosed;

//initialization
+(id)xmlTreeWithElementTag:(NSString *)name attributes:(NSDictionary *)attributes attributeOrder:(NSArray *)order contents:(NSString *)contents;
+(id)xmlTreeWithElementTag:(NSString *)name;


-(void)setAttributesDictionary:(NSDictionary *)attributes;
-(NSDictionary *)attributesDictionary;

-(void)setContentsString:(NSString *)aString;
-(NSString *)contentsString;
-(void)appendContentsString:(NSString *)string;
-(void)setBase16Contents:(NSData *)data;
-(NSData *)decodedBase16Contents;
-(void)setBase64Contents:(NSData *)data;
-(NSData *)decodedBase64Contents;
-(void)setLevel:(int)level;
-(int)level;

-(LITMXMLTree *)findXMLTreeElement:(NSString *)name;//not implemented

    //parent nodes
-(void)setParent:(LITMXMLTree *)aParent;
-(LITMXMLTree *)parent;
-(void)removeParent;

    //working with children
-(void)insertChild:(LITMXMLTree *)child atIndex:(int)index;
-(void)addChild:(LITMXMLTree *)child;
-(void)removeChild:(LITMXMLTree *)child;//this simply removes it from tree
-(void)removeChildAtIndex:(int)index;
-(int)childCount;
-(LITMXMLTree *)firstChild;
-(LITMXMLTree *)lastChild;
-(LITMXMLTree *)childAtIndex:(int)index;
-(int)indexOfChild:(LITMXMLTree *)child;
-(NSArray *)children;
-(BOOL)isExpandable;

//xml rendering
-(NSString *)xml;
-(NSString *)elementTag:(NSString *)levelIndent;
-(NSString *)xmlAttributeName:(NSString *)name value:(NSString *)value;
-(NSString *)closedElementTag:(NSString *)levelIndent;

-(void)addAttribute:(NSString *)name value:(NSString *)value;
-(void)removeAttributeWithName:(NSString *)name;

-(NSString *)childlessContentlessElementTag:(NSString *)name withIndent:(NSString *)levelIndent;


//working with colors
+(id)treeFromNSColor:(NSColor *)aColor withName:(NSString *)name;
-(NSColor *)colorFromTree;

//working with fonts
+(id)treeFromNSFont:(NSFont *)font withName:(NSString *)name;
-(NSFont *)fontFromTree;

+(id)treeFromNSRect:(NSRect)aRect;
-(NSRect)rectFromTree;
@end

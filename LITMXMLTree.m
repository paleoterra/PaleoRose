//
//  LITMXMLTree.m
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

#import "LITMXMLTree.h"
#import "LITMXMLBinaryEncoding.h"
 
@implementation LITMXMLTree
@synthesize _nodeParent,_nodeChildren,elementContents,elementName,elementAttributes,attributeOrder,elementType,isClosed;

+(id)xmlTreeWithElementTag:(NSString *)name attributes:(NSDictionary *)attributes attributeOrder:(NSArray *)order contents:(NSString *)contents;
{
    LITMXMLTree *aTree = [[LITMXMLTree alloc] init];
    [aTree setElementName:name];
    [aTree setAttributesDictionary:attributes];
    [aTree setAttributeOrder:[NSMutableArray arrayWithArray:order]];
    [aTree setContentsString:contents];
    return aTree;
}

+(id)xmlTreeWithElementTag:(NSString *)name
{
    LITMXMLTree *aTree = [[LITMXMLTree alloc] init];
    [aTree setElementName:name];
    [aTree setIsClosed:NO];
    return aTree;
}

-(id)init
{
    if(self = [super init])
    {
        [self setElementName:@"unnamed"];
        elementAttributes =  [[NSMutableDictionary alloc] init];
        attributeOrder = [[NSMutableArray alloc] init];
        _level = 0;
        _nodeChildren = [[NSMutableArray alloc] init];
		elementContents = [[NSString alloc] init];
        return self;
    }
    return nil;
}






-(void)setAttributesDictionary:(NSDictionary *)attributes
{
    [self setElementAttributes:[NSMutableDictionary dictionaryWithDictionary:attributes]];
}

-(NSDictionary *)attributesDictionary
{
    return elementAttributes;
}



-(void)setContentsString:(NSString *)aString
{
	if(aString)
		[self setElementContents:aString];
	else
		[self setElementContents:@""];
}

-(NSString *)contentsString
{
    return elementContents;
}

-(void)appendContentsString:(NSString *)string
{

    if(elementContents)
        elementContents = [elementContents stringByAppendingString:string];
    else
        elementContents = @"";
        
}

-(void)setBase16Contents:(NSData *)data
{
    [self setContentsString:encodeBase16(data)];
}

-(NSData *)decodedBase16Contents
{
    return decodeBase16(elementContents);
}

-(void)setBase64Contents:(NSData *)data
{
    [self setContentsString:encodeBase64(data)];
	
}

-(NSData *)decodedBase64Contents
{
    return decodeBase64(elementContents);
}

-(void)setLevel:(int)level
{
    _level = level;
    if([_nodeChildren count]>0)
    {
        NSEnumerator *anEnum = [_nodeChildren objectEnumerator];
        LITMXMLTree *aTree;
        while(aTree = [anEnum nextObject])
            [aTree setLevel:(_level +1)];
    }
}

-(int)level
{
    return _level;
}

-(LITMXMLTree *)findXMLTreeElement:(NSString *)name
{
    LITMXMLTree *theTarget,*current;
    theTarget = nil;
    NSEnumerator *theEnum = [_nodeChildren objectEnumerator];
    
    while(current = [theEnum nextObject])
    {
        if([[current elementName] isEqualToString:name])
        {
            theTarget = current;
            break;
        }
        else if([current isExpandable])
        {
            theTarget = [current findXMLTreeElement:name];
            if(theTarget)
                break;
        }
    }
    
    return theTarget;
}

    //parent nodes
-(void)setParent:(LITMXMLTree *)aParent
{
    [self set_nodeParent:aParent];
    [self setLevel:([aParent level]+1)];
}

-(LITMXMLTree *)parent
{
    return _nodeParent;
}

-(void)removeParent
{
    _nodeParent = nil;
    [self setLevel:0];
    
}

    //working with children
-(void)insertChild:(LITMXMLTree *)child atIndex:(int)index
{
    [_nodeChildren insertObject:child atIndex:index];
    [child setParent:self];
    [child setLevel:([self level]+1)];
}

-(void)addChild:(LITMXMLTree *)child
{
    [_nodeChildren addObject:child];
    [child setParent:self];
    [child setLevel:([self level]+1)];
}

-(void)removeChild:(LITMXMLTree *)child
{
    int index = (int)[_nodeChildren indexOfObject:child];
    [self removeChildAtIndex:index];
    
}

-(void)removeChildAtIndex:(int)index
{
    LITMXMLTree *child = [_nodeChildren objectAtIndex:index];
    [child removeParent];
    [child setLevel:0];
    [self removeChild:child];
}

-(int)childCount
{
    return (int)[_nodeChildren count];
}

-(LITMXMLTree *)firstChild
{
    return [_nodeChildren objectAtIndex:0];
}

-(LITMXMLTree *)lastChild
{
    return [_nodeChildren lastObject];
}

-(LITMXMLTree *)childAtIndex:(int)index
{
    return [_nodeChildren objectAtIndex:index];
}

-(int)indexOfChild:(LITMXMLTree *)child
{
    return (int)[_nodeChildren indexOfObject:child];
}

-(NSArray *)children
{
	return [NSArray arrayWithArray:_nodeChildren];
}

-(BOOL)isExpandable
{
    if([_nodeChildren count]>0)
        return YES;
    else
        return NO;
    
}

-(NSString *)xml
{
    NSMutableString *workingLevel = [[NSMutableString alloc] init];
    NSEnumerator *anEnum = [_nodeChildren objectEnumerator];
    LITMXMLTree *aTree;
    int i;
    NSMutableString *elementWithContents = [[NSMutableString alloc] init];

    for(i=0;i<[self level];i++)
    {
        [workingLevel appendString:@"\t"];
    }
    //empty xml tag
    if(([_nodeChildren count]==0)&&((![self contentsString])||([[self contentsString] length] < 1)))
    {
        return [self childlessContentlessElementTag:elementName withIndent:workingLevel];
    }
    //now, assemble XML
    [elementWithContents appendString:[self elementTag:[NSString stringWithString:workingLevel]]];
    if([self contentsString])
        [elementWithContents appendString:[self contentsString]];
    if([_nodeChildren count] > 0)
        [elementWithContents appendString:@"\n"];
    while(aTree = [anEnum nextObject])
    {
        [elementWithContents appendString:[aTree xml]];
    }
    [elementWithContents appendString:[self closedElementTag:workingLevel]];
    return [NSString stringWithString:elementWithContents];
}

-(NSString *)elementTag:(NSString *)levelIndent
{
    NSMutableString *theString = [[NSMutableString alloc] init];
    NSEnumerator *anEnum = [attributeOrder objectEnumerator];
    NSString *attName;
    [theString appendString:levelIndent];
    [theString appendFormat:@"<%@",elementName];
     
    while(attName = [anEnum nextObject]) 
        [theString appendString:[self xmlAttributeName:attName value:[elementAttributes objectForKey:attName]]];
    [theString appendString:@">"];
    return [NSString stringWithString:theString];
}

-(NSString *)xmlAttributeName:(NSString *)name value:(NSString *)value
{
    return [NSString stringWithFormat:@" %@=\"%@\"",name,value];
}

-(NSString *)closedElementTag:(NSString *)levelIndent
{
    NSMutableString *theString = [[NSMutableString alloc] init];
    if([_nodeChildren count]>0)
        [theString appendFormat:@"%@</%@>\n",levelIndent,elementName];
    else
        [theString appendFormat:@"</%@>\n",elementName];
    return [NSString stringWithString:theString];
}

-(void)addAttribute:(NSString *)name value:(NSString *)value
{
    [elementAttributes setObject:value forKey:name];
    [attributeOrder addObject:name];
}

-(void)removeAttributeWithName:(NSString *)name
{
    [elementAttributes removeObjectForKey:name];
    [attributeOrder removeObject:name];
}

-(NSString *)childlessContentlessElementTag:(NSString *)name withIndent:(NSString *)levelIndent
{
    NSMutableString *theString = [[NSMutableString alloc] init];
    NSEnumerator *anEnum = [attributeOrder objectEnumerator];
    NSString *attName;
    [theString appendString:levelIndent];
    [theString appendFormat:@"<%@",elementName];
    
    while(attName = [anEnum nextObject]) 
        [theString appendString:[self xmlAttributeName:attName value:[elementAttributes objectForKey:attName]]];
    [theString appendString:@"/>\n"];
    return [NSString stringWithString:theString];
}

+(id)treeFromNSColor:(NSColor *)aColor withName:(NSString *)name
{
	//NSLog(@"setting up color");
	CGFloat red, green, blue, alpha;
	NSColor *tempColor= [aColor colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];
	NSArray *attOrder = [NSArray arrayWithObjects:@"TYPE",@"RED",@"GREEN",@"BLUE",@"ALPHA",nil];
	NSMutableDictionary *aDict = [[NSMutableDictionary alloc] init];
	[tempColor getRed:&red green:&green blue:&blue alpha:&alpha];
	[aDict setObject:name forKey:@"TYPE"];
	[aDict setObject:[NSString stringWithFormat:@"%f",red] forKey:@"RED"];
	[aDict setObject:[NSString stringWithFormat:@"%f",green] forKey:@"GREEN"];
	[aDict setObject:[NSString stringWithFormat:@"%f",blue] forKey:@"BLUE"];
	[aDict setObject:[NSString stringWithFormat:@"%f",alpha] forKey:@"ALPHA"];
	//NSLog(@"returning color");
	return [LITMXMLTree xmlTreeWithElementTag:@"COLOR"
								   attributes:aDict 
							   attributeOrder:attOrder
									 contents:nil];
}

-(NSColor *)colorFromTree
{
	
	float red,blue,green,alpha;
	red = [[[self attributesDictionary] objectForKey:@"RED"] floatValue];
	green = [[[self attributesDictionary] objectForKey:@"GREEN"] floatValue];
	blue = [[[self attributesDictionary] objectForKey:@"BLUE"] floatValue];
	alpha = [[[self attributesDictionary] objectForKey:@"ALPHA"] floatValue];
	return [NSColor colorWithDeviceRed:red green:green blue:blue alpha:alpha];
}

+(id)treeFromNSFont:(NSFont *)font withName:(NSString *)name
{
	//NSLog(@"setting up font");
	NSArray *attOrder = [NSArray arrayWithObjects:@"FONTNAME",@"TYPE",@"SIZE",nil];
	NSDictionary *attDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[font fontName],name,[NSString stringWithFormat:@"%f",[font pointSize]],nil] forKeys:attOrder];
	//NSLog(@"returning font");
	return [LITMXMLTree xmlTreeWithElementTag:@"FONT" attributes:attDict attributeOrder:attOrder contents:nil];
}

-(NSFont *)fontFromTree
{
	return [NSFont fontWithName:[[self attributesDictionary] objectForKey:@"NAME"] size:[[[self attributesDictionary] objectForKey:@"NAME"]floatValue]];
}


+(id)treeFromNSRect:(NSRect)aRect
{
	NSArray *attOrder = [NSArray arrayWithObjects:@"X",@"Y",@"WIDTH",@"HEIGHT",nil];
	NSDictionary *attDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%f",aRect.origin.x],[NSString stringWithFormat:@"%f",aRect.origin.y],[NSString stringWithFormat:@"%f",aRect.size.width],[NSString stringWithFormat:@"%f",aRect.size.height],nil] forKeys:attOrder];
	return [LITMXMLTree xmlTreeWithElementTag:@"RECT" attributes:attDict attributeOrder:attOrder contents:nil];
}

-(NSRect)rectFromTree
{
	NSRect aRect = NSMakeRect([[[self attributesDictionary] objectForKey:@"X"] floatValue],[[[self attributesDictionary] objectForKey:@"Y"] floatValue],[[[self attributesDictionary] objectForKey:@"WIDTH"] floatValue],[[[self attributesDictionary] objectForKey:@"HEIGHT"] floatValue]);
	return aRect;
}
@end

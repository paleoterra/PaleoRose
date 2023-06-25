//
//  XRFileParser1.m
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

#import "XRFileParser1.h"
#import "LITMXMLTree.h"

@implementation XRFileParser1


-(LITMXMLTree *)documentBaseTree
{
	NSMutableDictionary *attDict = [[NSMutableDictionary alloc] init];
	NSMutableArray *attOrder = [[NSMutableArray alloc] init];
	[attDict setObject:@"1.0" forKey:@"VERSION"];
	[attOrder addObject:@"VERSION"];
	LITMXMLTree *theTree = [LITMXMLTree xmlTreeWithElementTag:@"XRose"
													attributes:attDict
												attributeOrder:attOrder 
													  contents:nil];
	
	return theTree;
}

-(NSDictionary *)dictionaryForDocumentTree:(LITMXMLTree *)theTree
{
	NSMutableDictionary *theDict = [[NSMutableDictionary alloc] init];
	NSArray *mainChildren = [theTree children];

	for(int i=0;i<[mainChildren count];i++)
	{
		//NSLog(@"child %i",i);
		if([[[mainChildren objectAtIndex:i] elementName] isEqualToString:@"GEOMETRY"])
			[theDict setObject:[self dictionarForGeometryControllerXMLTree:[mainChildren objectAtIndex:i]] forKey:@"geometrySettings"];
		else if([[[mainChildren objectAtIndex:i] elementName] isEqualToString:@"Layers"])
			[theDict setObject:[self dictionarForTableControllerXMLTree:[mainChildren objectAtIndex:i]] forKey:@"layersSettings"];
	}
	
	
	return theDict;
}
-(LITMXMLTree *)treeForGeometryControllerDictionary:(NSDictionary *)theDict
{
	//NSLog(@"treeForGeometryControllerDictionary start");
	LITMXMLTree *theTree;
	NSMutableDictionary *attDict = [[NSMutableDictionary alloc] init];
	NSMutableArray *attOrder = [[NSMutableArray alloc] init];
	
	[attDict setObject:[theDict objectForKey:@"_isEqualArea"] forKey:@"EQUAL"];
	[attOrder addObject:@"EQUAL"];
	
	[attDict setObject:[theDict objectForKey:@"_isPercent"] forKey:@"ISPERCENT"];
	[attOrder addObject:@"ISPERCENT"];
	
	theTree = [LITMXMLTree xmlTreeWithElementTag:@"GEOMETRY" attributes:attDict attributeOrder:attOrder contents:nil];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"MAX_COUNT" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_geometryMaxCount"]]];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"MAX_PERCENT" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_geometryMaxPercent"]]];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"HOLLOW_CORE_SIZE" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_hollowCoreSize"]]];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"SECTOR_SIZE" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_sectorSize"]]];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"START_ANGLE" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_startingAngle"]]];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"SECTOR_COUNT" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_sectorCount"]]];
	//NSLog(@"treeForGeometryControllerDictionary end");
	return theTree;
}

-(NSDictionary *)dictionarForGeometryControllerXMLTree:(LITMXMLTree *)theTree
{
	NSMutableDictionary *theDict = [[NSMutableDictionary alloc] init];
	NSDictionary *theAtts = [theTree attributesDictionary];
	//NSArray *children = [theTree children];
	NSString *tempString;
	if((tempString = [theAtts objectForKey:@"EQUAL"]))
		[theDict setObject:tempString forKey:@"_isEqualArea"];
	if((tempString = [theAtts objectForKey:@"ISPERCENT"]))
		[theDict setObject:tempString forKey:@"_isPercent"];
	if((tempString = [[theTree findXMLTreeElement:@"MAX_COUNT"] contentsString]))
		[theDict setObject:tempString forKey:@"_geometryMaxCount"];
	if((tempString = [[theTree findXMLTreeElement:@"MAX_PERCENT"] contentsString]))
		[theDict setObject:tempString forKey:@"_geometryMaxPercent"];
	if((tempString = [[theTree findXMLTreeElement:@"HOLLOW_CORE_SIZE"] contentsString]))
		[theDict setObject:tempString forKey:@"_hollowCoreSize"];
	if((tempString = [[theTree findXMLTreeElement:@"SECTOR_SIZE"] contentsString]))
		[theDict setObject:tempString forKey:@"_sectorSize"];
	if((tempString = [[theTree findXMLTreeElement:@"START_ANGLE"] contentsString]))
		[theDict setObject:tempString forKey:@"_startingAngle"];
	if((tempString = [[theTree findXMLTreeElement:@"SECTOR_COUNT"] contentsString]))
		[theDict setObject:tempString forKey:@"_sectorCount"];
	return theDict;
}

-(LITMXMLTree *)treeForTableControllerDictionary:(NSDictionary *)theDict
{
	NSArray *layers = [theDict objectForKey:@"layers"];
	NSEnumerator *anEnum = [layers objectEnumerator];
	NSDictionary *layerDict;
	LITMXMLTree *theTree = [LITMXMLTree xmlTreeWithElementTag:@"Layers"];
	while(layerDict = [anEnum nextObject])
	{
		[theTree addChild:[self treeForLayerDictionary:layerDict]];
	}
	return theTree;
}

-(NSDictionary *)dictionarForTableControllerXMLTree:(LITMXMLTree *)theTree
{
	NSMutableDictionary *theDict = [[NSMutableDictionary alloc] init];
	NSMutableArray *layers = [[NSMutableArray alloc] init];
	NSDictionary *tempDict;
	for(int i=0;i<[[theTree children] count];i++)
	{
		//NSLog(@"adding layer");
		if((tempDict = [self convertLayerTreeToDictionary:[theTree childAtIndex:i]]))
			[layers addObject:tempDict];
		
	}
	[theDict setObject:layers forKey:@"layers"];
	//NSLog(@"layer count %i", [layers count]);
	return theDict;
	
}

-(NSDictionary *)convertLayerTreeToDictionary:(LITMXMLTree *)theTree
{
	NSString *typeString = [[theTree attributesDictionary] objectForKey:@"TYPE"];
	
	if([typeString isEqualToString:@"GRID"])
	{
		//NSLog(@"doing grid");
		return [self dictionarForGridLayerXMLTree:theTree];
	}
	else if([typeString isEqualToString:@"CORE"])
	{
		
		return [self dictionarForCoreLayerXMLTree:theTree];
	}
	else if([typeString isEqualToString:@"DATA"])
	{
		//NSLog(@"doing data");
		return [self dictionarForDataLayerXMLTree:theTree];
	}
	else 
		return nil;
	/**** FINISH FOR ALL LAYER TYPES****/
}

-(LITMXMLTree *)treeForLayerDictionary:(NSDictionary *)aDict
{
	if([[aDict objectForKey:@"Layer_Type"] isEqualToString:@"Core_Layer"])
		return [self treeForCoreLayerDictionary:aDict];
	else if([[aDict objectForKey:@"Layer_Type"] isEqualToString:@"Data_Layer"])
		return [self treeForDataLayerDictionary:aDict];
	else
		return [self treeForGridLayerDictionary:aDict];
}

-(NSArray *)commonLayerAttributeOrder
{
	return [NSArray arrayWithObjects:@"TYPE",@"VISIBLE",@"ACTIVE",@"BIDIR",nil];
}

-(NSDictionary *)commonLayerAttributesFromDictionary:(NSDictionary *)aDict
{
	return [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[aDict objectForKey:@"Visible"],
		[aDict objectForKey:@"Active"],
		[aDict objectForKey:@"BIDIR"],
																 nil]
									   forKeys:[NSArray arrayWithObjects:@"VISIBLE",@"ACTIVE",@"BIDIR",nil]];
}

-(LITMXMLTree *)treeForGridLayerDictionary:(NSDictionary *)theDict
{
	//NSLog(@"setting up grid");
	NSMutableDictionary *attDict = [NSMutableDictionary dictionaryWithDictionary:[self commonLayerAttributesFromDictionary:theDict]];
	NSArray *attOrder = [self commonLayerAttributeOrder];
	NSDictionary *attDictSub;
	NSDictionary *ringDict = [theDict objectForKey:@"ringSettings"];
	NSDictionary *spokeDict = [theDict objectForKey:@"spokeSettings"];
	NSArray *graphicsArray;
	NSEnumerator *anEnum;
	NSDictionary *aGraphic;
	NSArray *attOrderSub; 
	LITMXMLTree *theTree;
	LITMXMLTree *theTreeRings;
	LITMXMLTree *theTreeSpokes;
	LITMXMLTree *theGraphics;
	//standard layer elements, some differences
	[attDict setObject:@"GRID" forKey:@"TYPE"];
	theTree = [LITMXMLTree xmlTreeWithElementTag:@"LAYER" attributes:attDict attributeOrder:attOrder contents:nil];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"NAME" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"Layer_Name"]]];
	[theTree addChild:[self treeFromNSColor:[theDict objectForKey:@"Stroke_Color"] withName:@"STROKE"]];
	[theTree addChild:[self treeFromNSColor:[theDict objectForKey:@"Fill_Color"] withName:@"FILL"]];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"WEIGHT" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"Line_Weight"]]];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"MAX_COUNT" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"Max_Count"]]];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"MAX_PERCENT" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"Max_Percent"]]];
	//end standard
	attOrderSub = [NSArray arrayWithObjects:@"FIXEDCOUNT",@"VISIBLE",@"LABELS",nil];
	attDictSub = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[ringDict objectForKey:@"FixedCount"],
		[ringDict objectForKey:@"RingsVisible"],
		[ringDict objectForKey:@"RingLabelsOn"],
		nil] forKeys:attOrderSub];
	theTreeRings = [LITMXMLTree xmlTreeWithElementTag:@"RINGS" attributes:attDictSub attributeOrder:attOrderSub contents:nil];
	[theTreeRings addChild:[LITMXMLTree xmlTreeWithElementTag:@"FIXEDCOUNT" attributes:nil attributeOrder:nil contents:[ringDict objectForKey:@"FixedRingCount"]]];
	[theTreeRings addChild:[LITMXMLTree xmlTreeWithElementTag:@"COUNT_INCREMENT" attributes:nil attributeOrder:nil contents:[ringDict objectForKey:@"RingCountIncrement"]]];
	[theTreeRings addChild:[LITMXMLTree xmlTreeWithElementTag:@"PERCENT_INCREMENT" attributes:nil attributeOrder:nil contents:[ringDict objectForKey:@"ringPercentIncrement"]]];
	[theTreeRings addChild:[LITMXMLTree xmlTreeWithElementTag:@"LABEL_ANGLE" attributes:nil attributeOrder:nil contents:[ringDict objectForKey:@"_labelAngle"]]];
	[theTreeRings addChild:[self treeFromNSFont:[ringDict objectForKey:@"ringLabelFont"]]];
	[theTree addChild:theTreeRings];
	
	
	attOrderSub = [NSArray arrayWithObjects:@"SECTORLOCK",@"VISIBLE",@"ISPERCENT",@"TICKS",@"MINOR_TICKS",@"LABELS",nil];
	attDictSub = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[spokeDict objectForKey:@"_spokeSectorLock"],
		[spokeDict objectForKey:@"_spokesVisible"],
		[spokeDict objectForKey:@"_isPercent"],
		[spokeDict objectForKey:@"_showTicks"],
		[spokeDict objectForKey:@"_minorTicks"],
		[spokeDict objectForKey:@"_showLabels"],
		nil] forKeys:attOrderSub];
	
	theTreeSpokes = [LITMXMLTree xmlTreeWithElementTag:@"SPOKES" attributes:attDictSub attributeOrder:attOrderSub contents:nil];
	[theTreeSpokes addChild:[LITMXMLTree xmlTreeWithElementTag:@"ALIGN" attributes:nil attributeOrder:nil contents:[spokeDict objectForKey:@"_spokeNumberAlign"]]];
	[theTreeSpokes addChild:[LITMXMLTree xmlTreeWithElementTag:@"COMPASS_POINT" attributes:nil attributeOrder:nil contents:[spokeDict objectForKey:@"_spokeNumberCompassPoint"]]];
	[theTreeSpokes addChild:[LITMXMLTree xmlTreeWithElementTag:@"NUMBER_ORDER" attributes:nil attributeOrder:nil contents:[spokeDict objectForKey:@"_spokeNumberOrder"]]];
	[theTreeSpokes addChild:[self treeFromNSFont:[spokeDict objectForKey:@"_spokeFont"]]];
	[theTreeSpokes addChild:[LITMXMLTree xmlTreeWithElementTag:@"SPOKE_COUNT" attributes:nil attributeOrder:nil contents:[spokeDict objectForKey:@"Spoke_Count"]]];
	[theTreeSpokes addChild:[LITMXMLTree xmlTreeWithElementTag:@"SPOKE_ANGLE" attributes:nil attributeOrder:nil contents:[spokeDict objectForKey:@"Spoke_Angle"]]];
	[theTree addChild:theTreeSpokes];
	
	theGraphics = [LITMXMLTree xmlTreeWithElementTag:@"GRAPHICS"];
	graphicsArray = [theDict objectForKey:@"Graphics"];
	anEnum = [graphicsArray objectEnumerator];
	while(aGraphic = [anEnum nextObject])
	{
		[theGraphics addChild:[self treeForGraphicDictionary:aGraphic]];
	}
	[theTree addChild:theGraphics];
	//NSLog(@"end up grid");
	return theTree;
}

-(NSDictionary *)dictionarForGridLayerXMLTree:(LITMXMLTree *)theTree
{
	NSMutableDictionary *theDict = [[NSMutableDictionary alloc] init];
	NSMutableDictionary *ringDict = [[NSMutableDictionary alloc] init];
	LITMXMLTree *ringTree;
	LITMXMLTree *spokeTree;
	LITMXMLTree *graphicTree;
	LITMXMLTree *tempTree;
	NSEnumerator *anEnum = [[theTree children] objectEnumerator];
	NSFont *tempFont;
	NSMutableDictionary *spokeDict = [[NSMutableDictionary alloc] init];
	
	NSString *tempString;

	[theDict setObject:@"Grid_Layer" forKey:@"Layer_Type"]; 
	//common elements
	[theDict setObject:[[theTree attributesDictionary] objectForKey:@"VISIBLE"] forKey:@"Visible"];
	[theDict setObject:[[theTree attributesDictionary] objectForKey:@"ACTIVE"] forKey:@"Active"];
	[theDict setObject:[[theTree attributesDictionary] objectForKey:@"BIDIR"] forKey:@"BIDIR"];
	//end common elements
	if((tempString = [[theTree findXMLTreeElement:@"NAME"] contentsString]))
		[theDict setObject:tempString forKey:@"Layer_Name"];
	
	while(tempTree = [anEnum nextObject])
	{
		if([[tempTree elementName] isEqualToString:@"COLOR"])
		{
			NSDictionary *theAttsDict = [tempTree attributesDictionary];
			if([[theAttsDict objectForKey:@"TYPE"] isEqualToString:@"STROKE"])
				[theDict setObject:[self colorFromTree:tempTree] forKey:@"Stroke_Color"];
			else
				[theDict setObject:[self colorFromTree:tempTree] forKey:@"Fill_Color"];
		}
	}
	

	if((tempString = [[theTree findXMLTreeElement:@"WEIGHT"] contentsString]))
		[theDict setObject:tempString forKey:@"Line_Weight"];
	if((tempString = [[theTree findXMLTreeElement:@"MAX_COUNT"] contentsString]))
		[theDict setObject:tempString forKey:@"Max_Count"];
	if((tempString = [[theTree findXMLTreeElement:@"MAX_PERCENT"] contentsString]))
		[theDict setObject:tempString forKey:@"Max_Percent"];
	
	if((ringTree = [theTree findXMLTreeElement:@"RINGS"]))
	{
		//attributes
		if((tempString = [[ringTree attributesDictionary] objectForKey:@"FIXEDCOUNT"]))
			[ringDict setObject:tempString forKey:@"FixedCount"];
		if((tempString = [[ringTree attributesDictionary] objectForKey:@"VISIBLE"]))
			[ringDict setObject:tempString forKey:@"RingsVisible"];
		if((tempString = [[ringTree attributesDictionary] objectForKey:@"LABELS"]))
			[ringDict setObject:tempString forKey:@"RingLabelsOn"];
		
		//children
		
		if((tempString = [[ringTree findXMLTreeElement:@"FIXEDCOUNT"] contentsString]))
			[ringDict setObject:tempString forKey:@"FixedRingCount"];
		if((tempString = [[ringTree findXMLTreeElement:@"COUNT_INCREMENT"] contentsString]))
			[ringDict setObject:tempString forKey:@"RingCountIncrement"];
		if((tempString = [[ringTree findXMLTreeElement:@"PERCENT_INCREMENT"] contentsString]))
			[ringDict setObject:tempString forKey:@"ringPercentIncrement"];
		if((tempString = [[ringTree findXMLTreeElement:@"LABEL_ANGLE"] contentsString]))
			[ringDict setObject:tempString forKey:@"_labelAngle"];
		if((tempFont = [self fontFromTree:[ringTree findXMLTreeElement:@"FONT"]]))
			[ringDict setObject:tempFont forKey:@"ringLabelFont"];
		
	}
	[theDict setObject:ringDict forKey:@"ringSettings"];
	
	if((spokeTree = [theTree findXMLTreeElement:@"SPOKES"]))
	{
		//attributes
		if((tempString = [[spokeTree attributesDictionary] objectForKey:@"SECTORLOCK"]))
			[spokeDict setObject:tempString forKey:@"_spokeSectorLock"];
		if((tempString = [[spokeTree attributesDictionary] objectForKey:@"VISIBLE"]))
			[spokeDict setObject:tempString forKey:@"_spokesVisible"];
		if((tempString = [[spokeTree attributesDictionary] objectForKey:@"ISPERCENT"]))
			[spokeDict setObject:tempString forKey:@"_isPercent"];
		if((tempString = [[spokeTree attributesDictionary] objectForKey:@"TICKS"]))
			[spokeDict setObject:tempString forKey:@"_showTicks"];
		if((tempString = [[spokeTree attributesDictionary] objectForKey:@"MINOR_TICKS"]))
			[spokeDict setObject:tempString forKey:@"_minorTicks"];
		if((tempString = [[spokeTree attributesDictionary] objectForKey:@"LABELS"]))
			[spokeDict setObject:tempString forKey:@"_showLabels"];
		
		//children
		if((tempString = [[spokeTree findXMLTreeElement:@"ALIGN"] contentsString]))
			[spokeDict setObject:tempString forKey:@"_spokeNumberAlign"];
		if((tempString = [[spokeTree findXMLTreeElement:@"COMPASS_POINT"] contentsString]))
			[spokeDict setObject:tempString forKey:@"_spokeNumberCompassPoint"];
		if((tempString = [[spokeTree findXMLTreeElement:@"NUMBER_ORDER"] contentsString]))
			[spokeDict setObject:tempString forKey:@"_spokeNumberOrder"];
		if((tempFont = [self fontFromTree:[spokeTree findXMLTreeElement:@"FONT"]]))
			[spokeDict setObject:tempFont forKey:@"_spokeFont"];
		if((tempString = [[spokeTree findXMLTreeElement:@"SPOKE_COUNT"] contentsString]))
			[spokeDict setObject:tempString forKey:@"Spoke_Count"];
		if((tempString = [[spokeTree findXMLTreeElement:@"SPOKE_ANGLE"] contentsString]))
			[spokeDict setObject:tempString forKey:@"Spoke_Angle"];
		
		
	}
	[theDict setObject:spokeDict forKey:@"spokeSettings"];
	
	if((graphicTree = [theTree findXMLTreeElement:@"GRAPHICS"]))
	{
		NSDictionary *tempDict;
		NSMutableArray *graphicArray = [[NSMutableArray alloc] init];
		for(int i=0;i<[[graphicTree children] count];i++)
		{
			if((tempDict = [self dictionarForGraphicXMLTree:[graphicTree childAtIndex:i]]))
			{
				[graphicArray addObject:tempDict];
			}
		}
		[theDict setObject:graphicArray forKey:@"Graphics"];
	}
	return theDict;
	
}

-(LITMXMLTree *)treeFromNSColor:(NSColor *)aColor withName:(NSString *)name
{
	//NSLog(@"setting up color");
	CGFloat red, green, blue, alpha;
    NSColor *tempColor= [aColor colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];;
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

-(NSColor *)colorFromTree:(LITMXMLTree *)theTree
{

	float red,blue,green,alpha;
	//NSLog([[theTree attributesDictionary] description]);
	if(!theTree)
		[[NSException exceptionWithName:@"Bad Color From File" reason:@"[XRFileParser1 colorFromTree:object] object is nil." userInfo:nil] raise];
	red = [[[theTree attributesDictionary] objectForKey:@"RED"] floatValue];
	green = [[[theTree attributesDictionary] objectForKey:@"GREEN"] floatValue];
	blue = [[[theTree attributesDictionary] objectForKey:@"BLUE"] floatValue];
	alpha = [[[theTree attributesDictionary] objectForKey:@"ALPHA"] floatValue];
	//NSLog(@"%f %f %f %f",red,green,blue,alpha);
	return [NSColor colorWithDeviceRed:red green:green blue:blue alpha:alpha];

	
	
	

}

-(LITMXMLTree *)treeFromNSFont:(NSFont *)font
{
	//NSLog(@"setting up font");
	NSArray *attOrder = [NSArray arrayWithObjects:@"NAME",@"SIZE",nil];
	NSDictionary *attDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[font fontName],[NSString stringWithFormat:@"%f",[font pointSize]],nil] forKeys:attOrder];
	//NSLog(@"returning font");
	return [LITMXMLTree xmlTreeWithElementTag:@"FONT" attributes:attDict attributeOrder:attOrder contents:nil];
}

-(NSFont *)fontFromTree:(LITMXMLTree *)theTree
{
	return [NSFont fontWithName:[[theTree attributesDictionary] objectForKey:@"NAME"] size:[[[theTree attributesDictionary] objectForKey:@"NAME"]floatValue]];
}

-(LITMXMLTree *)treeFromAttributedString:(NSAttributedString *)theString withTag:(NSString *)tag
{
	LITMXMLTree *theTree;
	NSRange aRange;
	aRange.location = 0;
	aRange.length = [theString length];
	theTree = [LITMXMLTree xmlTreeWithElementTag:tag];
    [theTree setBase64Contents:[theString RTFFromRange:aRange documentAttributes:@{}]];
	return theTree;
	
}

-(NSAttributedString *)attributedStringFromXMLTree:(LITMXMLTree *)theTree
{
	return [[NSAttributedString alloc] initWithRTF:[theTree decodedBase64Contents] documentAttributes:nil];
}

-(LITMXMLTree *)treeFromDataDictionary:(NSDictionary *)theDict
{
	NSMutableDictionary *attDict = [[NSMutableDictionary alloc] init];
	NSMutableArray *attOrder = [[NSMutableArray alloc] init];
	LITMXMLTree *theTree;
	NSAttributedString *comments;
	LITMXMLTree *theValueTree;
	float *values;
	NSData *theData = [theDict objectForKey:@"values"];
	[attDict setObject:[theDict objectForKey:@"name"] forKey:@"NAME"];
	[attOrder addObject:@"NAME"];
	
	theTree = [LITMXMLTree xmlTreeWithElementTag:@"DATASET" attributes:attDict attributeOrder:attOrder contents:nil];
	if((comments = [theDict objectForKey:@"comments"]))
	{
		[theTree addChild:[self treeFromAttributedString:comments withTag:@"COMMENTS"]];
	}
	theValueTree = [LITMXMLTree xmlTreeWithElementTag:@"VALUES"];
	values = (float *)malloc([theData length]);
    [theData getBytes:values length: [theData length]];
	for(int i=0;i<[theData length]/4;i++)
	{
		[theValueTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"RECORD" attributes:nil attributeOrder:nil contents:[NSString stringWithFormat:@"%f",values[i]]]];
		
	}
	[theTree addChild:theValueTree];
    free(values);
	return theTree;
	
}

-(NSDictionary *)dictionarForDataLayerXMLTree:(LITMXMLTree *)theTree
{
	NSMutableDictionary *theDict  = [[NSMutableDictionary alloc] init];
	NSDictionary *theAtts = [theTree attributesDictionary];
	NSString *tempString;

	NSMutableData *theData = [[NSMutableData alloc] init];
	LITMXMLTree *valuesTree;
	LITMXMLTree *tempTree;
	NSEnumerator *anEnum = [[theTree children] objectEnumerator];
	[theDict setObject:@"Data_Layer" forKey:@"Layer_Type"]; 
	if(theAtts)
	{
		if((tempString = [theAtts objectForKey:@"VISIBLE"]))
			[theDict setObject:tempString forKey:@"Visible"];
		if((tempString = [theAtts objectForKey:@"ACTIVE"]))
			[theDict setObject:tempString forKey:@"Active"];
		if((tempString = [theAtts objectForKey:@"BIDIR"]))
			[theDict setObject:tempString forKey:@"BIDIR"];
		
	}
	
	while(tempTree = [anEnum nextObject])
	{
		if([[tempTree elementName] isEqualToString:@"COLOR"])
		{
			NSDictionary *theAttsDict = [tempTree attributesDictionary];
			if([[theAttsDict objectForKey:@"TYPE"] isEqualToString:@"STROKE"])
				[theDict setObject:[self colorFromTree:tempTree] forKey:@"Stroke_Color"];
			else
				[theDict setObject:[self colorFromTree:tempTree] forKey:@"Fill_Color"];
		}
	}
	
	
	if((tempString = [[theTree findXMLTreeElement:@"NAME"] contentsString]))
		[theDict setObject:tempString forKey:@"Layer_Name"];
	if((tempString = [[theTree findXMLTreeElement:@"WEIGHT"] contentsString]))
		[theDict setObject:tempString forKey:@"Line_Weight"];
	if((tempString = [[theTree findXMLTreeElement:@"MAX_COUNT"] contentsString]))
		[theDict setObject:tempString forKey:@"Max_Count"];
	if((tempString = [[theTree findXMLTreeElement:@"MAX_PERCENT"] contentsString]))
		[theDict setObject:tempString forKey:@"Max_Percent"];
	if((tempString = [[theTree findXMLTreeElement:@"COUNT"] contentsString]))
		[theDict setObject:tempString forKey:@"Total_Count"];
	if((tempString = [[theTree findXMLTreeElement:@"DOTRADIUS"] contentsString]))
		[theDict setObject:tempString forKey:@"Dot_Radius"];
	if((tempString = [[theTree findXMLTreeElement:@"TYPE"] contentsString]))
		[theDict setObject:tempString forKey:@"Plot_Type"];
	

	if((valuesTree= [theTree findXMLTreeElement:@"VALUES"]))
	{
		float value;
		NSEnumerator *anEnum  = [[valuesTree children] objectEnumerator];
		LITMXMLTree *anItem;
		while(anItem = [anEnum nextObject])
		{
			value = [[anItem contentsString] floatValue];
			[theData appendBytes:&value length:sizeof(float)];
			
		}
		[theDict setObject:theData forKey:@"values"];
	}
	return theDict;
}

-(NSDictionary *)dictionarForGraphicXMLTree:(LITMXMLTree *)theTree
{
	if([[[theTree attributesDictionary] objectForKey:@"TYPE"] isEqualToString:@"CircleLabel"])
		return [self dictionarForGraphicCircleLabelXMLTree:theTree];
	else if([[[theTree attributesDictionary] objectForKey:@"TYPE"] isEqualToString:@"Circle"])
		return [self dictionarForGraphicCircleXMLTree:theTree];
	else if([[[theTree attributesDictionary] objectForKey:@"TYPE"] isEqualToString:@"Line"])
		return [self dictionarForGraphicLineXMLTree:theTree];
	else if([[[theTree attributesDictionary] objectForKey:@"TYPE"] isEqualToString:@"Kite"])
		return [self dictionarForGraphicKiteXMLTree:theTree];
	else if([[[theTree attributesDictionary] objectForKey:@"TYPE"] isEqualToString:@"Petal"])
		return [self dictionarForGraphicPetalXMLTree:theTree];
	else if([[[theTree attributesDictionary] objectForKey:@"TYPE"] isEqualToString:@"Dot"])
		return [self dictionarForGraphicDotXMLTree:theTree];
	else if([[[theTree attributesDictionary] objectForKey:@"TYPE"] isEqualToString:@"Histogram"])
		return [self dictionarForGraphicHistogramXMLTree:theTree];
	else if([[[theTree attributesDictionary] objectForKey:@"TYPE"] isEqualToString:@"DotDeviation"])
		return [self dictionarForGraphicDotDeviationXMLTree:theTree];
	else
		return nil;
}


-(LITMXMLTree *)treeForGraphicDictionary:(NSDictionary *)theDict
{
	if([[theDict objectForKey:@"GraphicType"] isEqualToString:@"LabelCircle"])
		return [self treeForGraphicCircleLabelDictionary:theDict];
	else if([[theDict objectForKey:@"GraphicType"] isEqualToString:@"Circle"])
		return [self treeForGraphicCircleDictionary:theDict];
	else if([[theDict objectForKey:@"GraphicType"] isEqualToString:@"Line"])
		return [self treeForGraphicLineDictionary:theDict];
	else if([[theDict objectForKey:@"GraphicType"] isEqualToString:@"Petal"])
		return [self treeForGraphicPetalDictionary:theDict];
	else if([[theDict objectForKey:@"GraphicType"] isEqualToString:@"Line"])
		return [self treeForGraphicLineDictionary:theDict];
	else if([[theDict objectForKey:@"GraphicType"] isEqualToString:@"Dot"])
		return [self treeForGraphicDotDictionary:theDict];
	else if([[theDict objectForKey:@"GraphicType"] isEqualToString:@"Histogram"])
		return [self treeForGraphicHistogramDictionary:theDict];
	else if([[theDict objectForKey:@"GraphicType"] isEqualToString:@"DotDeviation"])
		return [self treeForGraphicDotDeviationDictionary:theDict];
	else
		return nil;
}




-(LITMXMLTree *)treeForGraphicCircleDictionary:(NSDictionary *)theDict
{
	LITMXMLTree *theTree = [LITMXMLTree xmlTreeWithElementTag:@"GRAPHIC" attributes:[NSDictionary dictionaryWithObject:@"Circle" forKey:@"TYPE"] attributeOrder:[NSArray arrayWithObject:@"TYPE"] contents:nil];
	//add common children
	[theTree addChild:[self treeFromNSColor:[theDict objectForKey:@"_fillColor"] withName:@"FILL"]];
	[theTree addChild:[self treeFromNSColor:[theDict objectForKey:@"_strokeColor"] withName:@"STROKE"]];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"WIDTH" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_lineWidth"]]];
	//end commen children
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"GEOMETRY_PERCENT" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_isGeometryPercent"]]];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"ISPERCENT" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_isPercent"]]];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"FIXEDCOUNT" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_isFixedCount"]]];
	return theTree;
}

-(NSDictionary *)dictionarForGraphicCircleXMLTree:(LITMXMLTree *)theTree
{
	NSMutableDictionary *theDict = [[NSMutableDictionary alloc] init];
	NSString *tempString;
	LITMXMLTree *tempTree;
	if((tempTree = [theTree findXMLTreeElement:@"FILL"]))
		[theDict setObject:[self colorFromTree:tempTree] forKey:@"_fillColor"];
	if((tempTree = [theTree findXMLTreeElement:@"STROKE"]))
		[theDict setObject:[self colorFromTree:tempTree] forKey:@"_strokeColor"];

	if((tempString = [[theTree findXMLTreeElement:@"WIDTH"] contentsString]))
		[theDict setObject:tempString forKey:@"_lineWidth"];
	if((tempString = [[theTree findXMLTreeElement:@"GEOMETRY_PERCENT"] contentsString]))
		[theDict setObject:tempString forKey:@"_isGeometryPercent"];
	if((tempString = [[theTree findXMLTreeElement:@"ISPERCENT"] contentsString]))
		[theDict setObject:tempString forKey:@"_isPercent"];
	if((tempString = [[theTree findXMLTreeElement:@"FIXEDCOUNT"] contentsString]))
		[theDict setObject:tempString forKey:@"_isFixedCount"];
	
	

	
	return theDict;
}


-(LITMXMLTree *)treeForGraphicCircleLabelDictionary:(NSDictionary *)theDict
{
	LITMXMLTree *theTree = [LITMXMLTree xmlTreeWithElementTag:@"GRAPHIC" attributes:[NSDictionary dictionaryWithObject:@"CircleLabel" forKey:@"TYPE"] attributeOrder:[NSArray arrayWithObject:@"TYPE"] contents:nil];
	//add common children
	[theTree addChild:[self treeFromNSColor:[theDict objectForKey:@"_fillColor"] withName:@"FILL"]];
	[theTree addChild:[self treeFromNSColor:[theDict objectForKey:@"_strokeColor"] withName:@"STROKE"]];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"WIDTH" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_lineWidth"]]];
	//end commen children
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"GEOMETRY_PERCENT" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_isGeometryPercent"]]];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"ISPERCENT" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_isPercent"]]];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"FIXEDCOUNT" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_isFixedCount"]]];
	
	//unique to label version
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"LABELVISIBLE" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_showLabel"]]];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"LABELANGLE" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_labelAngle"]]];
	[theTree addChild:[self treeFromAttributedString:[theDict objectForKey:@"Label"] withTag:@"LABEL"]];
	[theTree addChild:[self treeFromNSFont:[theDict objectForKey:@"_labelFont"]]];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"CORE" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_isCore"]]];

	
	return theTree;
}

-(NSDictionary *)dictionarForGraphicCircleLabelXMLTree:(LITMXMLTree *)theTree
{
	NSMutableDictionary *theDict = [[NSMutableDictionary alloc] init];
 
	NSString *tempString;
	NSFont *tempFont;
	NSAttributedString *tempAttString;
	LITMXMLTree *tempTree;
	if((tempTree = [theTree findXMLTreeElement:@"FILL"]))
		[theDict setObject:[self colorFromTree:tempTree] forKey:@"_fillColor"];
	if((tempTree = [theTree findXMLTreeElement:@"STROKE"]))
		[theDict setObject:[self colorFromTree:tempTree] forKey:@"_strokeColor"];

	if((tempString = [[theTree findXMLTreeElement:@"WIDTH"] contentsString]))
		[theDict setObject:tempString forKey:@"_lineWidth"];
	if((tempString = [[theTree findXMLTreeElement:@"GEOMETRY_PERCENT"] contentsString]))
		[theDict setObject:tempString forKey:@"_isGeometryPercent"];
	if((tempString = [[theTree findXMLTreeElement:@"ISPERCENT"] contentsString]))
		[theDict setObject:tempString forKey:@"_isPercent"];
	if((tempString = [[theTree findXMLTreeElement:@"FIXEDCOUNT"] contentsString]))
		[theDict setObject:tempString forKey:@"_isFixedCount"];
	
	if((tempString = [[theTree findXMLTreeElement:@"LABELVISIBLE"] contentsString]))
		[theDict setObject:tempString forKey:@"_showLabel"];
	if((tempString = [[theTree findXMLTreeElement:@"LABELANGLE"] contentsString]))
		[theDict setObject:tempString forKey:@"_labelAngle"];
	if((tempAttString = [self attributedStringFromXMLTree:[theTree findXMLTreeElement:@"LABEL"]]))
		[theDict setObject:tempAttString forKey:@"_isFixedCount"];
	if((tempFont = [self fontFromTree:[theTree findXMLTreeElement:@"FONT"]]))
		[theDict setObject:tempFont forKey:@"_labelFont"];
	if((tempString = [[theTree findXMLTreeElement:@"CORE"] contentsString]))
		[theDict setObject:tempString forKey:@"_isCore"];
	
	
	
	return theDict;
}


-(LITMXMLTree *)treeForGraphicLineDictionary:(NSDictionary *)theDict
{
	LITMXMLTree *theTree = [LITMXMLTree xmlTreeWithElementTag:@"GRAPHIC" attributes:[NSDictionary dictionaryWithObject:@"Line" forKey:@"TYPE"] attributeOrder:[NSArray arrayWithObject:@"TYPE"] contents:nil];
	//add common children
	[theTree addChild:[self treeFromNSColor:[theDict objectForKey:@"_fillColor"] withName:@"FILL"]];
	[theTree addChild:[self treeFromNSColor:[theDict objectForKey:@"_strokeColor"] withName:@"STROKE"]];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"WIDTH" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_lineWidth"]]];
	//end commen children
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"RELATIVEPERCENT" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_relativePercent"]]];

	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"ANGLE" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_angleSetting"]]];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"TICKTYPE" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_tickType"]]];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"TICK" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_showTick"]]];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"ALIGN" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_spokeNumberAlign"]]];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"COMPASS_POINT" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_spokeNumberCompassPoint"]]];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"ORDER" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_spokeNumberOrder"]]];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"VISIBLELABEL" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_showLabel"]]];
	[theTree addChild:[self treeFromAttributedString:[theDict objectForKey:@"_lineLabel"] withTag:@"LABEL"]];
	[theTree addChild:[self treeFromNSFont:[theDict objectForKey:@"_currentFont"]]];
	return theTree;
}

-(NSDictionary *)dictionarForGraphicLineXMLTree:(LITMXMLTree *)theTree
{
	NSMutableDictionary *theDict = [[NSMutableDictionary alloc] init];

	NSString *tempString;
	NSFont *tempFont;
	NSAttributedString *tempAttString;
	LITMXMLTree *tempTree;
	if((tempTree = [theTree findXMLTreeElement:@"FILL"]))
		[theDict setObject:[self colorFromTree:tempTree] forKey:@"_fillColor"];
	if((tempTree = [theTree findXMLTreeElement:@"STROKE"]))
		[theDict setObject:[self colorFromTree:tempTree] forKey:@"_strokeColor"];
	if((tempString = [[theTree findXMLTreeElement:@"WIDTH"] contentsString]))
		[theDict setObject:tempString forKey:@"_lineWidth"];
	
	if((tempString = [[theTree findXMLTreeElement:@"ANGLE"] contentsString]))
		[theDict setObject:tempString forKey:@"_angleSetting"];
	if((tempString = [[theTree findXMLTreeElement:@"TICKTYPE"] contentsString]))
		[theDict setObject:tempString forKey:@"_tickType"];
	if((tempString = [[theTree findXMLTreeElement:@"TICK"] contentsString]))
		[theDict setObject:tempString forKey:@"_showTick"];
	if((tempString = [[theTree findXMLTreeElement:@"ALIGN"] contentsString]))
		[theDict setObject:tempString forKey:@"_spokeNumberAlign"];
	if((tempString = [[theTree findXMLTreeElement:@"COMPASS_POINT"] contentsString]))
		[theDict setObject:tempString forKey:@"_spokeNumberCompassPoint"];
	if((tempString = [[theTree findXMLTreeElement:@"ORDER"] contentsString]))
		[theDict setObject:tempString forKey:@"_spokeNumberOrder"];
	if((tempString = [[theTree findXMLTreeElement:@"VISIBLELABEL"] contentsString]))
		[theDict setObject:tempString forKey:@"_showLabel"];
	if((tempString = [[theTree findXMLTreeElement:@"RELATIVEPERCENT"] contentsString]))
		[theDict setObject:tempString forKey:@"_relativePercent"];
	if((tempAttString = [self attributedStringFromXMLTree:[theTree findXMLTreeElement:@"LABEL"]]))
		[theDict setObject:tempAttString forKey:@"_lineLabel"];
	if((tempFont = [self fontFromTree:[theTree findXMLTreeElement:@"FONT"]]))
		[theDict setObject:tempFont forKey:@"_currentFont"];
	
	return theDict;
}


-(LITMXMLTree *)treeForGraphicKiteDictionary:(NSDictionary *)theDict
{
	LITMXMLTree *theTree = [LITMXMLTree xmlTreeWithElementTag:@"GRAPHIC" attributes:[NSDictionary dictionaryWithObject:@"Kite" forKey:@"TYPE"] attributeOrder:[NSArray arrayWithObject:@"TYPE"] contents:nil];
	//add common children
	[theTree addChild:[self treeFromNSColor:[theDict objectForKey:@"_fillColor"] withName:@"FILL"]];
	[theTree addChild:[self treeFromNSColor:[theDict objectForKey:@"_strokeColor"] withName:@"STROKE"]];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"WIDTH" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_lineWidth"]]];
	//end commen children
	
	return theTree;
}

-(NSDictionary *)dictionarForGraphicKiteXMLTree:(LITMXMLTree *)theTree
{
	NSMutableDictionary *theDict = [[NSMutableDictionary alloc] init];
	NSString *tempString;

	LITMXMLTree *tempTree;
	if((tempTree = [theTree findXMLTreeElement:@"FILL"]))
		[theDict setObject:[self colorFromTree:tempTree] forKey:@"_fillColor"];
	if((tempTree = [theTree findXMLTreeElement:@"STROKE"]))
		[theDict setObject:[self colorFromTree:tempTree] forKey:@"_strokeColor"];
	if((tempString = [[theTree findXMLTreeElement:@"WIDTH"] contentsString]))
		[theDict setObject:tempString forKey:@"_lineWidth"];
	return theDict;
}


-(LITMXMLTree *)treeForGraphicPetalDictionary:(NSDictionary *)theDict
{
	LITMXMLTree *theTree = [LITMXMLTree xmlTreeWithElementTag:@"GRAPHIC" attributes:[NSDictionary dictionaryWithObject:@"Petal" forKey:@"TYPE"] attributeOrder:[NSArray arrayWithObject:@"TYPE"] contents:nil];
	//add common children
	[theTree addChild:[self treeFromNSColor:[theDict objectForKey:@"_fillColor"] withName:@"FILL"]];
	[theTree addChild:[self treeFromNSColor:[theDict objectForKey:@"_strokeColor"] withName:@"STROKE"]];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"WIDTH" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_lineWidth"]]];
	//end commen children
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"INCREMENT" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_petalIncrement"]]];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"MAXRADIUS" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_maxRadius"]]];

	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"PERCENT" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_percent"]]];

	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"COUNT" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_count"]]];

	
	return theTree;
}

-(NSDictionary *)dictionarForGraphicPetalXMLTree:(LITMXMLTree *)theTree
{
	NSMutableDictionary *theDict = [[NSMutableDictionary alloc] init];
	
	NSString *tempString;

	LITMXMLTree *tempTree;
	if((tempTree = [theTree findXMLTreeElement:@"FILL"]))
		[theDict setObject:[self colorFromTree:tempTree] forKey:@"_fillColor"];
	if((tempTree = [theTree findXMLTreeElement:@"STROKE"]))
		[theDict setObject:[self colorFromTree:tempTree] forKey:@"_strokeColor"];
	if((tempString = [[theTree findXMLTreeElement:@"WIDTH"] contentsString]))
		[theDict setObject:tempString forKey:@"_lineWidth"];
	
	if((tempString = [[theTree findXMLTreeElement:@"INCREMENT"] contentsString]))
		[theDict setObject:tempString forKey:@"_petalIncrement"];
	if((tempString = [[theTree findXMLTreeElement:@"MAXRADIUS"] contentsString]))
		[theDict setObject:tempString forKey:@"_maxRadius"];
	if((tempString = [[theTree findXMLTreeElement:@"PERCENT"] contentsString]))
		[theDict setObject:tempString forKey:@"_percent"];
	if((tempString = [[theTree findXMLTreeElement:@"COUNT"] contentsString]))
		[theDict setObject:tempString forKey:@"_count"];
	
	
	return theDict;
}


-(LITMXMLTree *)treeForGraphicDotDictionary:(NSDictionary *)theDict
{
	LITMXMLTree *theTree = [LITMXMLTree xmlTreeWithElementTag:@"GRAPHIC" attributes:[NSDictionary dictionaryWithObject:@"Dot" forKey:@"TYPE"] attributeOrder:[NSArray arrayWithObject:@"TYPE"] contents:nil];
	//add common children
	[theTree addChild:[self treeFromNSColor:[theDict objectForKey:@"_fillColor"] withName:@"FILL"]];
	[theTree addChild:[self treeFromNSColor:[theDict objectForKey:@"_strokeColor"] withName:@"STROKE"]];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"WIDTH" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_lineWidth"]]];
	//end commen children
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"INCREMENT" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_angleIncrement"]]];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"TOTAL" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_totalCount"]]];
	
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"DOTSIZE" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_dotSize"]]];
	
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"COUNT" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_count"]]];
	
	
	return theTree;
	
}

-(NSDictionary *)dictionarForGraphicDotXMLTree:(LITMXMLTree *)theTree
{
	NSMutableDictionary *theDict = [[NSMutableDictionary alloc] init];
	
	NSString *tempString;

	LITMXMLTree *tempTree;
	if((tempTree = [theTree findXMLTreeElement:@"FILL"]))
		[theDict setObject:[self colorFromTree:tempTree] forKey:@"_fillColor"];
	if((tempTree = [theTree findXMLTreeElement:@"STROKE"]))
		[theDict setObject:[self colorFromTree:tempTree] forKey:@"_strokeColor"];
	if((tempString = [[theTree findXMLTreeElement:@"WIDTH"] contentsString]))
		[theDict setObject:tempString forKey:@"_lineWidth"];
	
	if((tempString = [[theTree findXMLTreeElement:@"INCREMENT"] contentsString]))
		[theDict setObject:tempString forKey:@"_angleIncrement"];
	if((tempString = [[theTree findXMLTreeElement:@"TOTAL"] contentsString]))
		[theDict setObject:tempString forKey:@"_totalCount"];
	if((tempString = [[theTree findXMLTreeElement:@"DOTSIZE"] contentsString]))
		[theDict setObject:tempString forKey:@"_dotSize"];
	if((tempString = [[theTree findXMLTreeElement:@"COUNT"] contentsString]))
		[theDict setObject:tempString forKey:@"_count"];
	
	
	return theDict;
}


-(LITMXMLTree *)treeForGraphicHistogramDictionary:(NSDictionary *)theDict
{
	LITMXMLTree *theTree = [LITMXMLTree xmlTreeWithElementTag:@"GRAPHIC" attributes:[NSDictionary dictionaryWithObject:@"Histogram" forKey:@"TYPE"] attributeOrder:[NSArray arrayWithObject:@"TYPE"] contents:nil];
	//add common children
	[theTree addChild:[self treeFromNSColor:[theDict objectForKey:@"_fillColor"] withName:@"FILL"]];
	[theTree addChild:[self treeFromNSColor:[theDict objectForKey:@"_strokeColor"] withName:@"STROKE"]];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"WIDTH" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_lineWidth"]]];
	//end commen children
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"INCREMENT" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_histIncrement"]]];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"PERCENT" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_percent"]]];
	
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"COUNT" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_count"]]];
	
	return theTree;
}

-(NSDictionary *)dictionarForGraphicHistogramXMLTree:(LITMXMLTree *)theTree
{
	NSMutableDictionary *theDict = [[NSMutableDictionary alloc] init];
	
	NSString *tempString;

	LITMXMLTree *tempTree;
	if((tempTree = [theTree findXMLTreeElement:@"FILL"]))
		[theDict setObject:[self colorFromTree:tempTree] forKey:@"_fillColor"];
	if((tempTree = [theTree findXMLTreeElement:@"STROKE"]))
		[theDict setObject:[self colorFromTree:tempTree] forKey:@"_strokeColor"];
	if((tempString = [[theTree findXMLTreeElement:@"WIDTH"] contentsString]))
		[theDict setObject:tempString forKey:@"_lineWidth"];
	
	if((tempString = [[theTree findXMLTreeElement:@"INCREMENT"] contentsString]))
		[theDict setObject:tempString forKey:@"_histIncrement"];
	if((tempString = [[theTree findXMLTreeElement:@"PERCENT"] contentsString]))
		[theDict setObject:tempString forKey:@"_percent"];
	if((tempString = [[theTree findXMLTreeElement:@"COUNT"] contentsString]))
		[theDict setObject:tempString forKey:@"_count"];
	
	
	return theDict;
}


-(LITMXMLTree *)treeForGraphicDotDeviationDictionary:(NSDictionary *)theDict
{
	LITMXMLTree *theTree = [LITMXMLTree xmlTreeWithElementTag:@"GRAPHIC" attributes:[NSDictionary dictionaryWithObject:@"DotDeviation" forKey:@"TYPE"] attributeOrder:[NSArray arrayWithObject:@"TYPE"] contents:nil];
	//add common children
	[theTree addChild:[self treeFromNSColor:[theDict objectForKey:@"_fillColor"] withName:@"FILL"]];
	[theTree addChild:[self treeFromNSColor:[theDict objectForKey:@"_strokeColor"] withName:@"STROKE"]];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"WIDTH" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_lineWidth"]]];
	//end commen children
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"INCREMENT" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_angleIncrement"]]];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"TOTAL" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_totalCount"]]];
	
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"DOTSIZE" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_dotSize"]]];
	
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"COUNT" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_count"]]];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"MEAN" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"_mean"]]];

	return theTree;
}

-(NSDictionary *)dictionarForGraphicDotDeviationXMLTree:(LITMXMLTree *)theTree
{
	NSMutableDictionary *theDict = [[NSMutableDictionary alloc] init];
	
	NSString *tempString;
	
	
	LITMXMLTree *tempTree;
	if((tempTree = [theTree findXMLTreeElement:@"FILL"]))
		[theDict setObject:[self colorFromTree:tempTree] forKey:@"_fillColor"];
	if((tempTree = [theTree findXMLTreeElement:@"STROKE"]))
		[theDict setObject:[self colorFromTree:tempTree] forKey:@"_strokeColor"];
	if((tempString = [[theTree findXMLTreeElement:@"WIDTH"] contentsString]))
		[theDict setObject:tempString forKey:@"_lineWidth"];
	
	if((tempString = [[theTree findXMLTreeElement:@"INCREMENT"] contentsString]))
		[theDict setObject:tempString forKey:@"_angleIncrement"];
	if((tempString = [[theTree findXMLTreeElement:@"TOTAL"] contentsString]))
		[theDict setObject:tempString forKey:@"_totalCount"];
	if((tempString = [[theTree findXMLTreeElement:@"DOTSIZE"] contentsString]))
		[theDict setObject:tempString forKey:@"_dotSize"];
	if((tempString = [[theTree findXMLTreeElement:@"COUNT"] contentsString]))
		[theDict setObject:tempString forKey:@"_count"];
	if((tempString = [[theTree findXMLTreeElement:@"MEAN"] contentsString]))
		[theDict setObject:tempString forKey:@"_mean"];
	
	
	return theDict;
}

-(LITMXMLTree *)treeForCoreLayerDictionary:(NSDictionary *)theDict
{
	NSMutableDictionary *attDict = [NSMutableDictionary dictionaryWithDictionary:[self commonLayerAttributesFromDictionary:theDict]];
	NSMutableArray *attOrder = [NSMutableArray arrayWithArray:[self commonLayerAttributeOrder]];
	NSArray *graphicsArray;
	NSEnumerator *anEnum;
	NSDictionary *aGraphic;
	
	LITMXMLTree *theTree;
	LITMXMLTree *theGraphics;
	
	
	[attDict setObject:[theDict objectForKey:@"CORE_TYPE"] forKey:@"ISCORE"];
	[attOrder insertObject:@"ISCORE" atIndex:1];
	//standard layer elements, some differences
	[attDict setObject:@"CORE" forKey:@"TYPE"];
	theTree = [LITMXMLTree xmlTreeWithElementTag:@"LAYER" attributes:attDict attributeOrder:attOrder contents:nil];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"NAME" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"Layer_Name"]]];
	[theTree addChild:[self treeFromNSColor:[theDict objectForKey:@"Stroke_Color"] withName:@"STROKE"]];
	[theTree addChild:[self treeFromNSColor:[theDict objectForKey:@"Fill_Color"] withName:@"FILL"]];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"WEIGHT" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"Line_Weight"]]];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"MAX_COUNT" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"Max_Count"]]];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"MAX_PERCENT" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"Max_Percent"]]];
	//end standard
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"PERCENT" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"CORE_RADIUS"]]];

	theGraphics = [LITMXMLTree xmlTreeWithElementTag:@"GRAPHICS"];
	graphicsArray = [theDict objectForKey:@"Graphics"];
	anEnum = [graphicsArray objectEnumerator];
	while(aGraphic = [anEnum nextObject])
	{
		[theGraphics addChild:[self treeForGraphicDictionary:aGraphic]];
	}
	[theTree addChild:theGraphics];
	//NSLog(@"end up grid");
	return theTree;

}

-(LITMXMLTree *)treeForDataLayerDictionary:(NSDictionary *)theDict
{
	NSMutableDictionary *attDict = [NSMutableDictionary dictionaryWithDictionary:[self commonLayerAttributesFromDictionary:theDict]];
	NSMutableArray *attOrder = [NSMutableArray arrayWithArray:[self commonLayerAttributeOrder]];
	NSArray *graphicsArray;
	NSEnumerator *anEnum;
	NSDictionary *aGraphic;
	
	LITMXMLTree *theTree;
	LITMXMLTree *theGraphics;
	
	
	
	//standard layer elements, some differences
	[attDict setObject:@"DATA" forKey:@"TYPE"];
	theTree = [LITMXMLTree xmlTreeWithElementTag:@"LAYER" attributes:attDict attributeOrder:attOrder contents:nil];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"NAME" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"Layer_Name"]]];
	[theTree addChild:[self treeFromNSColor:[theDict objectForKey:@"Stroke_Color"] withName:@"STROKE"]];
	[theTree addChild:[self treeFromNSColor:[theDict objectForKey:@"Fill_Color"] withName:@"FILL"]];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"WEIGHT" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"Line_Weight"]]];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"MAX_COUNT" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"Max_Count"]]];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"MAX_PERCENT" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"Max_Percent"]]];
	//end standard
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"TYPE" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"Plot_Type"]]];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"COUNT" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"Total_Count"]]];
	[theTree addChild:[LITMXMLTree xmlTreeWithElementTag:@"DOTRADIUS" attributes:nil attributeOrder:nil contents:[theDict objectForKey:@"Dot_Radius"]]];
	[theTree addChild:[self treeFromDataDictionary:[theDict objectForKey:@"Data_Set"]]];
	
	
	theGraphics = [LITMXMLTree xmlTreeWithElementTag:@"GRAPHICS"];
	graphicsArray = [theDict objectForKey:@"Graphics"];
	anEnum = [graphicsArray objectEnumerator];
	while(aGraphic = [anEnum nextObject])
	{
		[theGraphics addChild:[self treeForGraphicDictionary:aGraphic]];
	}
	[theTree addChild:theGraphics];
	//NSLog(@"end up grid");
	return theTree;
	
}

@end

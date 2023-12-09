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

#import "XRDataInspector.h"
#import "XRLayerData.h"
#import "XRStatistic.h"
@implementation XRDataInspector

+(void)initialize
{
	//[XRDataInspector setKeys:[NSArray arrayWithObject:@"_lineWeightValue"] triggerChangeNotificationsForDependentKey:@"XRDataInspectorChangedLineWeight"];
	//[XRDataInspector setKeys:[NSArray arrayWithObject:@"setLineWeight"] triggerChangeNotificationsForDependentKey:@"XRDataInspectorChangedCircleSize"];

}
-(id)init
{
	if (!(self = [super init])) return nil;
	if(self)
	{
        [[NSBundle mainBundle] loadNibNamed:@"XRDataInspector"
                         owner:self
               topLevelObjects:nil];
	}
	return self;
}
-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)awakeFromNib
{
	//NSLog(@"XRDataInspector awakeFromNib");
	
	[_objectController setObjectClass:[XRLayerData class]];
}
-(void)setInspectedObject:(XRLayerData *)anObject
{
	_object = anObject;
	//stats view
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statisticsDidChange:) name:XRLayerDataStatisticsDidChange object:anObject];
	//main view
	//[_setName setStringValue:[_object layerName]];
	//[_appearencePopUp selectItemAtIndex:0];
	
	
	//appearence view changeMainView
	//[_lineColor setColor:[_object strokeColor]];
	//[_fillColor setColor:[_object fillColor]];
	
	 
	//_lineWeightValue = [_object lineWeight];
	//_circleSizeValue = [_object dotRadius]; 
	
	//[_typePopUp selectItemAtIndex:[_object plotType]];
	//stat view
	[_objectController setContent:_object];
	[_objectController setObjectClass:[XRLayerData class]];
	//NSLog([[_object statisticsArray] description]);
	[_arrayController setContent:[_object statisticsArray]];
	
	//if([_objectController content]==nil)
		//NSLog(@"nil content");
	//[_objectController prepareContent];
	[self changeMainView:_appearencePopUp];
}

- (IBAction)changeCircleSize:(id)sender
{
	//[_object setDotRadius:_circleSizeValue];
}

- (IBAction)changeColor:(id)sender
{
	//if(sender == _lineColor)
		//[_object setStrokeColor:[_lineColor color]];
	//else
		//[_object setFillColor:[_fillColor color]];
}

- (IBAction)changeLineWeight:(id)sender
{
	//NSLog(@"lineweight original");
	//[_object setLineWeight:[sender floatValue]];
}

- (IBAction)changeMainView:(id)sender
{
	
	if([sender indexOfSelectedItem]==0)
	{
		[_statView removeFromSuperview];
		[_subview addSubview:_appearView];
	}
	else
	{
		[_appearView removeFromSuperview];
		[_subview addSubview:_statView];
	}
}

- (IBAction)changeName:(id)sender
{
	//[_object setLayerName:[sender stringValue]];
}

- (IBAction)changeType:(id)sender
{
	//[_object setPlotType:[sender indexOfSelectedItem]];

		
}


-(NSView *)contentView
{
	return _contentView;
}

-(void)statisticsDidChange:(id)sender
{
	[_arrayController setContent:[_object statisticsArray]];
}

-(IBAction)exportStatistics:(id)sender
{
}

-(IBAction)copyStatistics:(id)sender
{
	NSPasteboard *theBoard = [NSPasteboard generalPasteboard];
    [theBoard declareTypes:[NSArray arrayWithObject:NSPasteboardTypeString] owner:self];
    if([theBoard setString:[self selectedStatsString] forType:NSPasteboardTypeString])
		NSLog(@"copied");
}

-(NSString *)selectedStatsString
{
	NSIndexSet *theSet;
	NSMutableString *aString = [[NSMutableString alloc] init];
	XRStatistic *theStat;

	if([_statisticsTable numberOfSelectedRows] == 0)
	{
		//select all
		NSRange aRange;
		aRange.location = 0;
		aRange.length = [_statisticsTable numberOfRows];
		theSet = [[NSIndexSet alloc] initWithIndexesInRange:aRange];
	}
	else
	{
		theSet = [_statisticsTable selectedRowIndexes];
	}
	
	for(int i=0;i<[_statisticsTable numberOfRows];i++)
	{
		if([theSet containsIndex:i])
		{
			if((theStat = [[_object statisticsArray] objectAtIndex:i]))
			{
				[aString appendFormat:@"%@ = %@\n",theStat.statisticName,[theStat valueString]];
			}
		}
	}
	return aString;
}
@end

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

#import "XRGeometryInspector.h"
#import "XRGeometryController.h"
#import <PaleoRose-Swift.h>
@implementation XRGeometryInspector

-(id)init
{
	if (!(self = [super init])) return nil;
	if(self)
	{
        [[NSBundle mainBundle] loadNibNamed:@"XRGeometryInspector"
                         owner:self
               topLevelObjects:nil];
	}
	return self;
}

-(void)awakeFromNib
{
	//NSLog(@"XRGeometryInspector inspector awake");
	[_systemPopup selectItemAtIndex:0];
	[_subView addSubview:_gridView];
}

-(void)setInspectedObject:(XRGeometryController *)anObject
{
	//NSLog(@"setInspectedObject");
	_object = anObject;
	NSNumberFormatter *aFormatter;
	//populate fields
	if([ _object isEqualArea])
		[_gridTypePopup selectItemAtIndex:0];
	else
		[_gridTypePopup selectItemAtIndex:1];
	[_relativeSizeBox setFloatValue:[_object relativeSizeOfCircleRect]];
	[_relativeSizeStepper setFloatValue:[_object relativeSizeOfCircleRect]];
	if([ _object isPercent])
	{
		[_unitsPopup selectItemAtIndex:1];
		[_maxSizeStepper setMinValue:1.0];
		[_maxSizeStepper setMaxValue:100.0];
		[_maxSizeStepper setFloatValue:([_object geometryMaxPercent]*100.0)];
		[_maxSizeTextBox takeFloatValueFrom:_maxSizeStepper];
		aFormatter = [[NSNumberFormatter alloc] init]  ;
		[aFormatter setFormat:@"0.00"];
		[_maxSizeTextBox setFormatter:aFormatter];
	}
	else
	{
		[_unitsPopup selectItemAtIndex:0];
		[_maxSizeStepper setMinValue:1.0];
		[_maxSizeStepper setMaxValue:1000000000.0];
		
		[_maxSizeStepper setIntValue:([_object geometryMaxCount])];
		[_maxSizeTextBox takeIntValueFrom:_maxSizeStepper];
		aFormatter = [[NSNumberFormatter alloc] init]  ;
		[aFormatter setFormat:@"0"];
		[_maxSizeTextBox setFormatter:aFormatter];
	}
	[_maxSizeStepper setIncrement:1.0];
	[_hollowCoreSizeStepper setMinValue:0.0];
	[_hollowCoreSizeStepper setMaxValue:95.0];
	[_hollowCoreSizeStepper setFloatValue:[_object hollowCoreSize]];
	[_hollowCoreSizeTextBox takeFloatValueFrom:_hollowCoreSizeStepper];
    [_hollowCoreSizeStepper setIncrement:1.0];
	
	
	[_countStepper setMaxValue:720.0];
	[_countStepper setMinValue:4.0];
	[_countStepper setIncrement:1.0];
    [_sectorAngle setFormatter:[FormatterFactory angleFormatter]];
	[_sectorAngle setFloatValue:[_object sectorSize]];
	[_countStepper setIntValue:(int)(360.0/[_sectorAngle floatValue])];
	[_sectorCount takeFloatValueFrom:_countStepper];
	
	[_startAngleStepper setMinValue:0.0];
	[_startAngleStepper setIncrement:1.0];
	[_startAngleStepper setMaxValue:[_sectorAngle floatValue]];
	[_startAngleStepper setFloatValue:[_object startingAngle]];
	[_startAngleTextBox setFormatter:[FormatterFactory angleFormatter]];
	[_startAngleTextBox takeFloatValueFrom:_startAngleStepper];

}

-(NSView *)contentView
{
	return _contentView;
}

- (IBAction)changeGridType:(id)sender
{
	if([sender indexOfSelectedItem] == 0)//equal area
	{
		[_object setEqualArea:YES];
		
	}
	else
		[_object setEqualArea:NO];
}

- (IBAction)changeHollowCore:(id)sender
{
	//NSLog(@"changeHollowCore");
	if(sender == _hollowCoreSizeStepper)
		[_hollowCoreSizeTextBox takeFloatValueFrom:_hollowCoreSizeStepper];
	else
		[_hollowCoreSizeStepper takeFloatValueFrom:_hollowCoreSizeTextBox];
	[_object setHollowCoreSize:([_hollowCoreSizeStepper floatValue]/100.0)];
}

- (IBAction)changeMaxValue:(id)sender
{
	//NSLog(@"changeMaxValue");
	if([_unitsPopup indexOfSelectedItem]==0)// count
	{
		if(sender==_maxSizeTextBox)
			[_maxSizeStepper takeIntValueFrom:_maxSizeTextBox];
		else
			[_maxSizeTextBox takeIntValueFrom:_maxSizeStepper];
		[_object setGeomentryMaxCount:[_maxSizeTextBox intValue]];
		//NSLog(@"box setting %i",[_maxSizeTextBox intValue]);
	}
	else// count
	{
		if(sender==_maxSizeTextBox)
			[_maxSizeStepper takeFloatValueFrom:_maxSizeTextBox];
		else
			[_maxSizeTextBox takeFloatValueFrom:_maxSizeStepper];
		[_object setGeomentryMaxPercent:([_maxSizeStepper floatValue]/100.0)];
	}
}

- (IBAction)changeSectorSize:(id)sender
{
	if(sender == _sectorAngle)
	{
		float angle = [_sectorAngle floatValue];
		int count = (int)(360.0/angle);
		angle = 360.0/(float)count;
		[_sectorAngle setFloatValue:angle];
		[_sectorCount setIntValue:count];
		[_countStepper setIntValue:count];
	} else if (sender == _sectorCount) {
		int count = [_sectorCount intValue];
		float angle = 360.0/(float)count;
		[_sectorAngle setFloatValue:angle];
		[_sectorCount setIntValue:count];
		[_countStepper setIntValue:count];
	} else {
		int count = [_countStepper intValue];
		float angle = 360.0/(float)count;
		[_sectorAngle setFloatValue:angle];
		[_sectorCount setIntValue:count];
		[_countStepper setIntValue:count];
	}
	[_object setSectorCount:[_sectorCount intValue]];
	[_startAngleStepper setMaxValue:[_sectorAngle floatValue]];
	if([_startAngleTextBox floatValue]>[_startAngleStepper maxValue])
	{
		//[_startAngleStepper setFloatValue:[_sectorAngle floatValue]];
		[_startAngleTextBox setFloatValue:[_startAngleStepper floatValue]];
		[_object setStartingAngle:[_startAngleStepper floatValue]];
	}
	
}

- (IBAction)changeStartAngle:(id)sender
{
	if(sender == _startAngleStepper)
		[_startAngleTextBox setFloatValue:[_startAngleStepper floatValue]];
	else
	{
		if([_startAngleTextBox floatValue]<=[_sectorAngle floatValue])
			[_startAngleStepper setFloatValue:[_startAngleTextBox floatValue]];
		else
		{
			[_startAngleTextBox setFloatValue:[_sectorAngle floatValue]];
			[_startAngleStepper setFloatValue:[_startAngleTextBox floatValue]];
		}
	}
	[_object setStartingAngle:[_startAngleStepper floatValue]];
}

-(IBAction)autoCalcMaxValue:(id)sender
{
	//NSLog(@"autocalc");
	if([_object isPercent])
	{
		[_object calculateGeometryMaxPercent];
		//update the max value line
		[_maxSizeTextBox setFloatValue:([_object geometryMaxPercent] * 100.0)];
		[_maxSizeStepper takeFloatValueFrom:_maxSizeTextBox];
	}
	else {
		[_object calculateGeometryMaxCount];
		//update the max value line
		[_maxSizeTextBox setIntValue:[_object geometryMaxCount]];
		[_maxSizeStepper takeIntValueFrom:_maxSizeTextBox];
	}
}
- (IBAction)changeSystem:(id)sender
{
	//NSLog(@"changeSystem");
	if([[sender titleOfSelectedItem] isEqualToString:@"Sector System"])
	{
		[_gridView removeFromSuperview];
		[_subView addSubview:_sectorView];
	}
	else
	{
		[_sectorView removeFromSuperview];
		[_subView addSubview:_gridView];
	}
}

- (IBAction)changeUnits:(id)sender
{
	//NSLog(@"changeUnits");
	NSNumberFormatter *aFormatter;
	if([sender indexOfSelectedItem] == 0)//count
	{
		[_object setPercent:NO];
		[_maxSizeTextBox setIntValue:[_object geometryMaxCount]];
		[_maxSizeStepper takeIntValueFrom:_maxSizeTextBox];
		aFormatter = [[NSNumberFormatter alloc] init]  ;
		[aFormatter setFormat:@"0"];
		[_maxSizeTextBox setFormatter:aFormatter];
	}
	else
	{
		[_object setPercent:YES];
		[_maxSizeTextBox setFloatValue:([_object geometryMaxPercent]*100.0)];
		[_maxSizeStepper takeFloatValueFrom:_maxSizeTextBox];
		aFormatter = [[NSNumberFormatter alloc] init]  ;
		[aFormatter setFormat:@"0.00"];
		[_maxSizeTextBox setFormatter:aFormatter];
	}
}

-(IBAction)changeRelativeSize:(id)sender
{
	float value;
	if(sender == _relativeSizeBox)
	{
		value = [_relativeSizeBox floatValue];
	}
	else
	{
		value = [_relativeSizeStepper floatValue];
	}
	if((value >= .5)&&(value<=1.0))
	{
	[_object setRelativeSizeOfCircleRect:[_relativeSizeStepper floatValue]];
	}
	else
	{
		value = [_object relativeSizeOfCircleRect];
	}
	[_relativeSizeBox setFloatValue:value];
	[_relativeSizeStepper setFloatValue:value];
	
}
@end

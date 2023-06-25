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

#import "XRGridInspector.h"
#import "XRLayerGrid.h"
#import "LITMPercentFormatter.h"

@implementation XRGridInspector
-(id)init
{
	if (!(self = [super init])) return nil;
	if(self)
	{
        [[NSBundle mainBundle] loadNibNamed:@"XRGridInspector"
                         owner:self
               topLevelObjects:nil];
		[_viewPopup selectItemAtIndex:0];
		[_spokeFont removeAllItems];
		[_spokeFont addItemsWithObjectValues:[[[NSFontManager sharedFontManager] availableFonts] sortedArrayUsingSelector:@selector(compare:)]];

		[_ringFont removeAllItems];
		//[_ringFont addItemsWithTitles:[[[NSFontManager sharedFontManager] availableFonts] sortedArrayUsingSelector:@selector(compare:)]];
		[_ringFont addItemsWithObjectValues:[[[NSFontManager sharedFontManager] availableFonts] sortedArrayUsingSelector:@selector(compare:)]];
		//[self changeView:self];
	}
	return self;
}

-(void)awakeFromNib
{
	[_ringPercentBox setFormatter:[[LITMPercentFormatter alloc] init]];
}

-(void)setInspectedObject:(XRLayerGrid *)anObject
{
	_object = anObject;
	[_objectController setContent:_object];
	[_objectController setObjectClass:[XRLayerGrid class]];
	[self changeView:_viewPopup];
}

-(NSView *)contentView
{
	return _contentView;
}

-(IBAction)requireTableReload:(id)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerTableRequiresReload object:_object];
}

-(IBAction)requireRedraw:(id)sender
{
	
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:_object];
}

-(IBAction)changeView:(id)sender
{
	
	if([[_subView subviews] count]>0)
	{
		NSView *aView = [[_subView subviews] objectAtIndex:0];
		[aView removeFromSuperview];
	}
	if([sender indexOfSelectedItem]==0)
	{
		
		[_subView addSubview:_appearView];
	}
	else if([sender indexOfSelectedItem]==1)
	{
		
		[_subView addSubview:_radialView];
	}
	else if([sender indexOfSelectedItem]==2)
	{
		//NSLog(@"tick");
		[_subView addSubview:_radialTickLabel];
		//[_spokeFont selectItemWithTitle:[[_object spokeFont] fontName]];
		[_spokeFontSizeStepper setIntValue:[[_object spokeFont] pointSize]];
		[_spokeFontSize setIntValue:[[_object spokeFont] pointSize]];
		[_spokeFont selectItemWithObjectValue:[[_object ringFont] fontName]];
	}
	else if([sender indexOfSelectedItem]==3)
	{

		[_subView addSubview:_circleView];
	}
	else
	{
		[_subView addSubview:_ringFontView];
		//[_ringFont selectItemWithTitle:[[_object ringFont] fontName]];
		[_ringFontSizeStepper setIntValue:[[_object ringFont] pointSize]];
		[_ringFontSize setIntValue:[[_object ringFont] pointSize]];
		[_ringFont selectItemWithObjectValue:[[_object ringFont] fontName]];
	}
}

-(IBAction)changeRadialCountsAndAngles:(id)sender
{
	if(sender == _spokeAngleBox)
	{
		[_object spokeAngleDidChange];
	}
	else
		[_object spokeCountDidChange];
	
	[_object generateGraphics];
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:_object];
}

-(IBAction)requireNewGraphics:(id)sender
{

	[_object generateGraphics];
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:_object];
	
}

-(void)changeFont:(id)sender
{
	
	NSFont *newFont;
	if((sender == _spokeFontSize)||(sender == _spokeFontSizeStepper)||(sender == _spokeFont))
	{
		if(sender == _spokeFontSize)
			[_spokeFontSizeStepper setIntValue:[_spokeFontSize intValue]];
		else if(sender == _spokeFontSizeStepper)
			[_spokeFontSize setIntValue:[_spokeFontSizeStepper intValue]];

		newFont = [NSFont fontWithName:[_spokeFont objectValueOfSelectedItem] size:[_ringFontSize floatValue]];
		[_object setSpokeFont:newFont];
	}
	else
	{
		if(sender == _ringFontSize)
			[_ringFontSizeStepper setIntValue:[_ringFontSize intValue]];
		else if(sender == _ringFontSizeStepper)
			[_ringFontSize setIntValue:[_ringFontSizeStepper intValue]];
		
		//newFont = [NSFont fontWithName:[_ringFont titleOfSelectedItem] size:[_ringFontSize floatValue]];
		newFont = [NSFont fontWithName:[_ringFont objectValueOfSelectedItem] size:[_ringFontSize floatValue]];
		[_object setRingFont:newFont];
	}
	
}

-(IBAction)changeCircleCountsAndAngles:(id)sender
{
	//if(sender == _ringCountBox)
	//{
		//[_ringCountStepper setIntValue: [_ringCountBox intValue]];
	//}
	//else if(sender == _ringCountStepper)
		//[_ringCountBox setIntValue: [_ringCountStepper intValue]];
	
	[_object generateGraphics];
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:_object];
}

@end

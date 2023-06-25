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

#import "XRCoreInspector.h"
#import "XRLayerCore.h"
@implementation XRCoreInspector

-(id)init
{
	if (!(self = [super init])) return nil;
	if(self)
	{
        [[NSBundle mainBundle] loadNibNamed:@"XRLayerCore"
                         owner:self
               topLevelObjects:nil];
	}
	return self;
}

-(void)setInspectedObject:(XRLayerCore *)anObject
{
	_object = anObject;
	[_objectController setContent:_object];
	[_objectController setObjectClass:[XRLayerCore class]];
	[self changeView:_viewPopup];
	
}
-(void)awakeFromNib
{
	//NSLog(@"XRDataInspector awakeFromNib");
	
	[_objectController setObjectClass:[XRLayerCore class]];
	//[_objectController setContent:nil];
	[self changeView:_viewPopup];
	
}

- (IBAction)changeView:(id)sender
{
	NSEnumerator *anEnum = [[_subView subviews] objectEnumerator];
	NSView *aView;
	while(aView = [anEnum nextObject])
		[aView removeFromSuperview];
	switch([sender indexOfSelectedItem])
	{
		case 0:
			[_subView addSubview:_typeView];
			break;
		case 1:
			[_subView addSubview:_appearView];
			break;
		default:
			break;
	}
}

- (IBAction)requireNewGraphics:(id)sender
{
	
	[_object generateGraphics];
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:_object];
}

- (IBAction)requireRedraw:(id)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:_object];
}

- (IBAction)requireRedrawAndTable:(id)sender
{
	//NSLog(@"redraw");
	[_object resetColorImage];
	[_object generateGraphics];
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:_object];
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerTableRequiresReload object:_object];
}

- (IBAction)requireTableReload:(id)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:XRLayerTableRequiresReload object:_object];
}

-(NSView *)contentView
{
	return _contentView;
}
@end

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

#import "XRVectorInspector.h"
#import "XRLayerLineArrow.h"
@implementation XRVectorInspector

-(id)init
{
	if (!(self = [super init])) return nil;
	if(self)
	{
		[[NSBundle mainBundle] loadNibNamed:@"XRVectorInspector"
                         owner:self
               topLevelObjects:nil];
	}
	return self;
}

-(void)awakeFromNib
{
	[_objectController setObjectClass:[XRLayerLineArrow class]];
	//[_objectController setContent:nil];
}

- (IBAction)viewRequiresChange:(id)sender
{
	[_object generateGraphics];
}

-(void)setInspectedObject:(XRLayerLineArrow *)anObject
{
	_object = anObject;
	[_objectController setContent:_object];
	[_objectController setObjectClass:[XRLayerLineArrow class]];
}

-(NSView *)contentView
{
	return _customView;
}
@end

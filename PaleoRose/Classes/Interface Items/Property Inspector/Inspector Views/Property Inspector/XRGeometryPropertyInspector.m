//
//  XRGeometryPropertyInspector.m
//  XRose
//
//  Created by Tom Moore on Wed Mar 17 2004.
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

#import "XRGeometryPropertyInspector.h"
#import "XRGeometryInspector.h"
#import "XRGeometryController.h"

static XRGeometryPropertyInspector *_defaultInspector;

@implementation XRGeometryPropertyInspector
-(id)init
{
	if (!(self = [super initWithWindowNibName:@"XRPropertyInspector"])) return nil;
	if(self)
	{
		//create subviews and controllers for different inspector groups
		
		//add inspectors
		_inspectorController = [[XRGeometryInspector alloc] init];
		[self displayInfoForObject:nil];

	}
	return self;
}

+(id)defaultGeometryInspector
{
	if(_defaultInspector)
		return _defaultInspector;
	else
	{
		_defaultInspector = [[XRGeometryPropertyInspector alloc] init];
		return _defaultInspector;
	}
}

-(IBAction)toggleInspector:(id)sender
{
	[self toggleInspectorWindow];
}

-(void)toggleInspectorWindow
{
	if([[self window] isVisible])
		[[self window] orderOut:self];
	else
		[[self window] orderFront:self];
}

-(void)displayInfoForObject:(id)object
{
	//NSLog([object description]);
	if([object isKindOfClass:[XRGeometryController class]])
	{
		
		[[self window] setContentView:[_inspectorController contentView]];
		[(XRGeometryInspector *)_inspectorController setInspectedObject:object];
	}
	else 
		[[self window] setContentView:nil];
}

-(void)awakeFromNib
{
	[[self window] setTitle:@"Geometry Inspector"];
}
@end

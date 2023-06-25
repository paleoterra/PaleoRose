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

#import "XRPropertyInspector.h"
#import "XREmptyInspectorController.h"
#import "XRGeometryInspector.h"
#import "XRGeometryController.h"
#import "XRDataInspector.h"
#import "XRGridInspector.h"
#import "XRCoreInspector.h"
#import "XRVectorInspector.h"
#import "XRLayerCore.h"
#import "XRLayerLineArrow.h"
#import "XRLayerData.h"
#import "XRLayerGrid.h"
static XRPropertyInspector *_defaultInspector;
@implementation XRPropertyInspector

-(id)init
{
	if (!(self = [super initWithWindowNibName:@"XRPropertyInspector"])) return nil;
	if(self)
	{
		//create subviews and controllers for different inspector groups
		_inspectorControllers = [[NSMutableDictionary alloc] init];
		//add inspectors
		[_inspectorControllers setObject:[[XREmptyInspectorController alloc] init] forKey:XRInspectorEmpty];
		[_inspectorControllers setObject:[[XRGeometryInspector alloc] init] forKey:XRInspectorGeometry];
		[_inspectorControllers setObject:[[XRDataInspector alloc] init] forKey:XRInspectorData];
		[_inspectorControllers setObject:[[XRCoreInspector alloc] init] forKey:XRInspectorCore];
		[_inspectorControllers setObject:[[XRGridInspector alloc] init] forKey:XRInspectorGrid];
		[_inspectorControllers setObject:[[XRVectorInspector alloc] init] forKey:XRInspectorVector];
		
		//set an empty view
		[self displayInfoForObject:nil];
		
	}
	return self;
}

+(id)defaultInspector
{
	if(_defaultInspector)
		return _defaultInspector;
	else
	{
		_defaultInspector = [[XRPropertyInspector alloc] init];
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
	if([object isKindOfClass:[XRLayerData class]])
	{
		
		[[self window] setContentView:[[_inspectorControllers objectForKey:XRInspectorData] contentView]];
		[(XRDataInspector *)[_inspectorControllers objectForKey:XRInspectorData] setInspectedObject:object];
	}
	else if([object isKindOfClass:[XRGeometryController class]])
	{
		
		[[self window] setContentView:[[_inspectorControllers objectForKey:XRInspectorGeometry] contentView]];
		[(XRGeometryInspector *)[_inspectorControllers objectForKey:XRInspectorGeometry] setInspectedObject:object];
	}
	else if([object isKindOfClass:[XRLayerGrid class]])
	{
		//NSLog(@"setting grid inspector");
		[[self window] setContentView:[[_inspectorControllers objectForKey:XRInspectorGrid] contentView]];
		[(XRGeometryInspector *)[_inspectorControllers objectForKey:XRInspectorGrid] setInspectedObject:object];
	}
	else if([object isKindOfClass:[XRLayerCore class]])
	{
		[[self window] setContentView:[[_inspectorControllers objectForKey:XRInspectorCore] contentView]];
		[(XRCoreInspector *)[_inspectorControllers objectForKey:XRInspectorCore] setInspectedObject:object];
	}
	else if([object isKindOfClass:[XRLayerLineArrow class]])
	{
		[[self window] setContentView:[[_inspectorControllers objectForKey:XRInspectorVector] contentView]];
		[(XRVectorInspector *)[_inspectorControllers objectForKey:XRInspectorVector] setInspectedObject:object];
	}
	else
		[[self window] setContentView:[[_inspectorControllers objectForKey:XRInspectorEmpty] contentView]];
}
@end

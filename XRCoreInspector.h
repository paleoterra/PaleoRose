/* XRCoreInspector */
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

#import <Cocoa/Cocoa.h>

@class XRLayerCore;
@interface XRCoreInspector : NSObject
{
    IBOutlet id _appearView;
    IBOutlet id _contentView;
    IBOutlet id _objectController;
    IBOutlet id _subView;
    IBOutlet id _typeView;
    IBOutlet id _viewPopup;
	XRLayerCore *_object;
}
- (IBAction)changeView:(id)sender;
- (IBAction)requireNewGraphics:(id)sender;
- (IBAction)requireRedraw:(id)sender;
- (IBAction)requireRedrawAndTable:(id)sender;
- (IBAction)requireTableReload:(id)sender;
-(NSView *)contentView;
-(void)setInspectedObject:(XRLayerCore *)anObject;
@end

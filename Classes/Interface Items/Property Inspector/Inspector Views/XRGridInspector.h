/* XRGridInspector */
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
@class XRLayerGrid;
@interface XRGridInspector : NSObject
{
    IBOutlet id _objectController;
	IBOutlet id _contentView;
	IBOutlet id _subView;
	IBOutlet id _circleView;
	IBOutlet id _radialView;
	IBOutlet id _viewPopup;
	IBOutlet id _spokeAngleBox;
	IBOutlet id _appearView;
	IBOutlet id _radialTickLabel;
	IBOutlet id _spokeFont;
	IBOutlet id _spokeFontSize;
	IBOutlet id _spokeFontSizeStepper;
	IBOutlet id _ringCountBox;
	IBOutlet id _ringCountStepper;
	IBOutlet id _ringPercentBox;
	IBOutlet id _ringFont;
	IBOutlet id _ringFontSize;
	IBOutlet id _ringFontSizeStepper;
	IBOutlet id _ringFontView;

	XRLayerGrid *_object;
}

-(void)setInspectedObject:(XRLayerGrid *)anObject;
-(NSView *)contentView;
-(IBAction)requireTableReload:(id)sender;
-(IBAction)changeView:(id)sender;
-(IBAction)requireRedraw:(id)sender;
-(IBAction)requireNewGraphics:(id)sender;
-(void)changeFont:(id)sender;
@end

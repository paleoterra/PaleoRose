/* XRGeometryInspector */
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
@class XRGeometryController;
@interface XRGeometryInspector : NSObject
{
	XRGeometryController *_object;
	//top level
	IBOutlet id _systemPopup;
	IBOutlet id _contentView;
	IBOutlet id _subView;
	//grid system
	IBOutlet id _gridView;
    
	IBOutlet id _gridTypePopup;
	IBOutlet id _unitsPopup;
	IBOutlet id _maxSizeStepper;
    IBOutlet id _maxSizeTextBox;
	IBOutlet id _hollowCoreSizeStepper;
    IBOutlet id _hollowCoreSizeTextBox;
	//sector
	IBOutlet id _sectorView;
	IBOutlet id _sectorAngle;
    IBOutlet id _sectorCount;
    IBOutlet id _countStepper;
    IBOutlet id _startAngleTextBox;
    IBOutlet id _startAngleStepper;
   
    NSNumberFormatter *theMaxSizeFormatter;
    
    //relative size
	IBOutlet id _relativeSizeBox;
	IBOutlet id _relativeSizeStepper;
    
    
    
    
}

-(void)setInspectedObject:(XRGeometryController *)anObject;
- (IBAction)changeGridType:(id)sender;
- (IBAction)changeHollowCore:(id)sender;
- (IBAction)changeMaxValue:(id)sender;
- (IBAction)changeSectorSize:(id)sender;
- (IBAction)changeStartAngle:(id)sender;
- (IBAction)changeSystem:(id)sender;
- (IBAction)changeUnits:(id)sender;
-(IBAction)autoCalcMaxValue:(id)sender;
-(NSView *)contentView;
-(IBAction)changeRelativeSize:(id)sender;
@end

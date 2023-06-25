/* XRDataInspector */
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
@class XRLayerData;
@interface XRDataInspector : NSObject
{
	XRLayerData *_object;
	//main level
	IBOutlet id _contentView;
    IBOutlet id _appearencePopUp;
	//IBOutlet id _setName;
	IBOutlet id _subview;
	//appear view
    IBOutlet id _appearView;
    //IBOutlet id _circleSizeSlider;
    IBOutlet id _statisticsTable;
	//float _circleSizeValue;
    //IBOutlet id _fillColor;
    //IBOutlet id _lineColor;
    //IBOutlet id _lineWeightSlider;
    //IBOutlet id _lineWeightBox;
	//float _lineWeightValue;
    IBOutlet id _typePopUp;
	IBOutlet id _arrayController;
	//stats
	IBOutlet id _statView;
	
	IBOutlet id _objectController;

}

-(void)setInspectedObject:(XRLayerData *)anObject;
-(NSView *)contentView;
- (IBAction)changeCircleSize:(id)sender;
- (IBAction)changeColor:(id)sender;
- (IBAction)changeLineWeight:(id)sender;
- (IBAction)changeMainView:(id)sender;
- (IBAction)changeName:(id)sender;
- (IBAction)changeType:(id)sender;
-(void)statisticsDidChange:(id)sender;
-(NSString *)selectedStatsString;
@end

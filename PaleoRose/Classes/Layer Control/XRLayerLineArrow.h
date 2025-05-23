//
//  XRLayerLineArrow.h
//  XRose
//
//  Created by Tom Moore on Sun Mar 14 2004.
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
#import <Cocoa/Cocoa.h>
#import "XRLayer.h"

@class XRDataSet;
@interface XRLayerLineArrow : XRLayer {
	XRDataSet *_theSet;
	float _arrowSize;
	int _type;
	int _headType;
	BOOL _showVector;
	BOOL _showError;
}

-(id)initWithGeometryController:(XRGeometryController *)aController withSet:(XRDataSet *)aSet;
-(void)configureErrorWithVector:(float)vAngle error:(float)error;
-(id)initWithIsVisible:(BOOL)visible
              active:(BOOL)active
               biDir:(BOOL)isBiDir
                name:(NSString *)layerName
          lineWeight:(float)lineWeight
            maxCount:(int)maxCount
          maxPercent:(float)maxPercent
           strokeColor:(NSColor *)strokeColor
             fillColor:(NSColor *)fillColor
             arrowSize:(float)arrowSize
            vectorType:(int)vectorType
             arrowType:(int)arrowType
            showVector:(BOOL)showVector
             showError:(BOOL)showError;

-(int)datasetId;
-(float)arrowSize;
-(int)vectorType;
-(int)arrowType;
-(BOOL)showVector;
-(BOOL)showError;
@end

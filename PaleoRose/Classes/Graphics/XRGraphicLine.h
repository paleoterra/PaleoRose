//
//  XRGraphicLine.h
//  XRose
//
//  Created by Tom Moore on Mon Jan 26 2004.
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
#import "XRGraphic.h"

//tick marks
#define XRGraphicLineTickTypeNone   0
#define XRGraphicLineTickTypeMinor  1
#define XRGraphicLineTickTypeMajor  2
//numbering order
#define XRGraphicLineNumberingOrder360  0
#define XRGraphicLineNumberingOrderQuad 1
//#define XRGraphicLineNumberingOrderPointOnly 2

//numbering angle
#define XRGraphicLineNumberAlignHorizontal  0
#define XRGraphicLineNumberAligAngle		1

//numbering compass point
#define XRGraphicLineNumberNumbersOnly  0
#define XRGraphicLineNumberPoints		1

@interface XRGraphicLine : XRGraphic

@property (readwrite) int tickType;
@property (readwrite) BOOL showTick;
@property (readwrite) BOOL spokePointOnly;
@property (readwrite) int spokeNumberAlign;
@property (readwrite) BOOL showLabel;
@property (readwrite) int spokeNumberCompassPoint;
@property (readwrite) int spokeNumberOrder;

@property (readwrite) float spokeAngle;

@property (nonatomic, strong, nullable) NSFont *font;
@property (nonatomic, strong, nullable) NSMutableAttributedString *lineLabel;
@property (nonatomic, strong, nullable) NSAffineTransform *labelTransform;

@end

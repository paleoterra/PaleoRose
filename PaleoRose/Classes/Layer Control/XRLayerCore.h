//
//  XRLayerCore.h
//  XRose
//
//  Created by Tom Moore on Thu Feb 05 2004.
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

#define XRLayerCoreTypeOverlay NO
#define XRLayerCoreTypeHollow YES


#define XRLayerCoreXMLCoreType @"CORE_TYPE"
#define XRLayerCoreXMLCoreRadius @"CORE_RADIUS"

@interface XRLayerCore : XRLayer {
	BOOL _coreType;
	NSImage *_corePattern;
	float _percentRadius;
}

-(id)initWithIsVisible:(BOOL)visible
              active:(BOOL)active
               biDir:(BOOL)isBiDir
                name:(NSString *)layerName
            lineWeight:(float)lineWeight
              maxCount:(int)maxCount
            maxPercent:(float)maxPercent
           strokeColor:(NSColor *)strokeColor
             fillColor:(NSColor *)fillColor
         percentRadius:(float)percentRadius
                  type:(BOOL)coreType;

-(BOOL)coreRadiusIsEditable;
-(BOOL)coreType;
-(float)radius;
@end

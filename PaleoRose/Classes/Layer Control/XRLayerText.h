//
//  XRLayerText.h
//  XRose
//
//  Created by Tom Moore on Mon Mar 29 2004.
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
@class NSLayoutManager;
@interface XRLayerText : XRLayer <NSTextViewDelegate> {
    NSTextStorage *_contents;
    NSRect textBounds;
    float estimatedRadius;
    float estimatedAngle;
    NSTextView *tempView;
    float gutter;
}

-(id)initWithGeometryController:(XRGeometryController *)aController parentView:(NSView *)view;
-(id)initWithGeometryController:(XRGeometryController *)aController xmlTree:(LITMXMLTree *)configureTree forVersion:(NSString *)version withParentView:(NSView *)aParent;

-(id)initWithIsVisible:(BOOL)visible
                active:(BOOL)active
                 biDir:(BOOL)isBiDir
                  name:(NSString *)layerName
            lineWeight:(float)lineWeight
              maxCount:(int)maxCount
            maxPercent:(float)maxPercent
              contents:(NSData *)contents
           rectOriginX:(float)rectOriginX
           rectOriginY:(float)rectOriginY
             rectWidth:(float)rectWidth
             rectWidth:(float)rectWidth;


- (void)setContents:(id)contents;
- (NSTextStorage *)contents;
-(NSRect)imageBounds;
-(NSImage *)dragImage;
-(void)moveToPoint:(NSPoint)newPoint;
//static NSLayoutManager *sharedDrawingLayoutManager();
-(void)displayTextFieldForEditing:(NSEvent *)theEvent;
-(void)removeTextFieldAfterEditing:(NSEvent *)theEvent;

-(NSString *)encodedContents;
-(NSRect)textRect;
@end

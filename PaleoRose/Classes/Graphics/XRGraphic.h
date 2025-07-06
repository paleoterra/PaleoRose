//
//  XRGraphic.h
//  XRose
//
//  Created by Tom Moore on Tue Jan 06 2004.
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

NS_ASSUME_NONNULL_BEGIN

@class XRGeometryController;

@interface XRGraphic : NSObject {


	NSBezierPath *_drawingPath;
	float _lineWidth;
    BOOL _needsDisplay;
    BOOL _drawsFill;
	__weak XRGeometryController *geometryController;
}

@property (nonatomic, nullable) NSColor *fillColor;
@property (nonatomic, nullable) NSColor *strokeColor;

-(id)initWithController:(XRGeometryController *)controller;
-(void)geometryDidChange:(NSNotification *)aNotification;
-(void)calculateGeometry;

-(void)setNeedsDisplay:(BOOL)display;
-(BOOL)needsDisplay;

-(NSRect)drawingRect;
-(void)drawRect:(NSRect )aRect;

- (BOOL)hitTest:(NSPoint)point;

-(void)setDrawsFill:(BOOL)fill;
-(BOOL)drawsFill;

-(void)setDefaultStrokeColor;

-(void)setDefaultFillColor;

-(void)setLineColor:(nullable NSColor *)aLineColor fillColor:(nullable NSColor *)aFillColor;

-(void)setTransparency:(float)alpha;

-(void)setLineWidth:(float)newWeight;
-(float)lineWidth;

-(NSDictionary *)graphicSettings;
@end

NS_ASSUME_NONNULL_END

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

#define XRGraphicKeyFillColor @"XRGraphicKeyFillColor"
#define XRGraphicKeyStrokeColor @"XRGraphicKeyStrokeColor"
#define XRGraphicKeyLineWidth @"XRGraphicKeyLineWidth"
#define XRGraphicKeyDrawsFill @"XRGraphicKeyDrawsFill"

@class XRGeometryController,LITMXMLTree;
@interface XRGraphic : NSObject {
	NSBezierPath *_drawingPath;
    NSColor *_fillColor;
    NSColor *_strokeColor;
	float _lineWidth;
    BOOL _needsDisplay;
    BOOL _drawsFill;
    BOOL _isSelected;
	__weak XRGeometryController *geometryController;
}

//Initialization
-(id)initWithController:(XRGeometryController *)controller;
//calculate Rose Geometry
-(void)geometryDidChange:(NSNotification *)aNotification;
-(void)calculateGeometry;

//redraw
-(void)setNeedsDisplay:(BOOL)display;
-(BOOL)needsDisplay;
//tests whether an object is within a rect.  If so, then needs display will return a YES
-(NSRect)drawingRect;//if this object needs redrawing, then use this to get its rect
-(void)drawRect:(NSRect )aRect;


	//hit test
- (BOOL)hitTest:(NSPoint)point;

	//selection
-(BOOL)isSelected;
-(void)setSelected:(BOOL)newSelection;
-(void)selectGraphic;
-(void)deselectGraphic;

	//inspector info
-(NSDictionary *)inspectorInfo;


	//Color
-(void)setDrawsFill:(BOOL)fill;
-(BOOL)drawsFill;

-(NSColor *)strokeColor;
-(void)setStrokeColor:(NSColor *)aColor;
-(void)setDefaultStrokeColor;

-(NSColor *)fillColor;
-(void)setFillColor:(NSColor *)aColor;
-(void)setDefaultFillColor;

-(void)setLineColor:(NSColor *)aLineColor fillColor:(NSColor *)aFillColor;

-(void)setTransparency:(float)alpha;

-(void)setLineWidth:(float)newWeight;
-(float)lineWidth;


-(BOOL)compareColor:(NSColor *)color1 withColor:(NSColor *)color2;
-(NSData *)dataFromColor:(NSColor *)aColor;
-(NSColor *)colorFromData:(NSData *)data;

-(NSDictionary *)graphicSettings;
@end

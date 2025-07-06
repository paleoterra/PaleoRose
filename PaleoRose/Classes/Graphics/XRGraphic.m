//
//  XRGraphic.m
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

#import "XRGraphic.h"
#import "XRGeometryController.h"
#import <math.h>

@implementation XRGraphic

-(instancetype)initWithController:(XRGeometryController *)controller {
    if (!(self = [super init])) return nil;
    if(self)
    {
        self.fillColor = [NSColor blackColor];
        self.strokeColor = [NSColor blackColor];
        self.lineWidth = 1.0;
        _needsDisplay = YES;
        _drawsFill = NO;
        _geometryController = controller;

        [self addObserver:self
               forKeyPath:@"lineWidth"
                  options:NSKeyValueObservingOptionNew |
         NSKeyValueObservingOptionOld
                  context:NULL];
    }
    return self;
}

-(void)geometryDidChange:(NSNotification *)aNotification {
    [self calculateGeometry];
}

-(void)calculateGeometry {
    //here subclasses must set up the geometry of the graphic object.
}

-(NSRect)drawingRect {
    return [self.drawingPath bounds];
}

-(void)drawRect:(NSRect)aRect {
    @try {
        if(NSIntersectsRect(aRect,[self.drawingPath bounds])) {
            [NSGraphicsContext saveGraphicsState];

            [self.strokeColor set];
            [self.drawingPath stroke];
            if(_drawsFill) {
                [self.fillColor set];
                [self.drawingPath fill];
            }
            [NSGraphicsContext restoreGraphicsState];
            self.needsDisplay = false;
        }
    }
    @catch (NSException *exception){
        NSLog(@"%@:drawRect: Caught %@: %@",[self className], [exception name], [exception reason]);
    }
}

- (BOOL)hitTest:(NSPoint)point {
    return NO;
}

-(void)setDefaultStrokeColor {
    self.strokeColor = [NSColor blackColor];
    return;
}

-(void)setDefaultFillColor {
    self.fillColor = [NSColor blackColor];
}

-(void)setTransparency:(float)alpha {
    NSColor *temp;
    float clampedAlpha = MAX(0.0, MIN(alpha, 1.0));
    if(!self.strokeColor)
        [self setDefaultStrokeColor];
    temp = [self.strokeColor colorWithAlphaComponent:clampedAlpha];
    if(temp) {
        self.strokeColor = temp;
    }
    temp = nil;

    if(!self.fillColor)
        [self setDefaultFillColor];
    temp = [self.fillColor colorWithAlphaComponent:clampedAlpha];
    if(temp) {
        self.fillColor = temp;
    }
    return;
}

-(void)setLineColor:(NSColor *)aLineColor fillColor:(NSColor *)aFillColor {
    self.strokeColor = aLineColor;
    self.fillColor = aFillColor;
}

-(NSDictionary *)graphicSettings {
    NSMutableDictionary *theDict = [[NSMutableDictionary alloc] init];
    [theDict setObject:@"Graphic" forKey:@"GraphicType"];

    [theDict setObject:self.fillColor forKey:@"_fillColor"];
    [theDict setObject:self.strokeColor forKey:@"_strokeColor"];
    [theDict setObject:[NSString stringWithFormat:@"%f",self.lineWidth] forKey:@"_lineWidth"];
    //NSLog(@"end general graphic");
    return [NSDictionary dictionaryWithDictionary:theDict];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {

    if ([keyPath isEqualToString:@"lineWidth"]) {
        if(self.drawingPath)
            [self.drawingPath setLineWidth:self.lineWidth];
    }
}
@end

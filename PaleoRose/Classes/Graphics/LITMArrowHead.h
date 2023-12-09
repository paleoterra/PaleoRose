//
//  LITMArrowHead.h
//  LITMAppKit
//
//  Created by Tom Moore on Sat Mar 13 2004.
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

#import <Foundation/Foundation.h>


@interface LITMArrowHead : NSObject {
	NSColor *_arrowColor;
	float _scale;
	int _type;
	NSBezierPath *_path;
	NSAffineTransform *_positionTransform;
	NSAffineTransform *_scaleTransform;
	NSPoint _targetPoint;
	float _angle;
}

-(id)initWithSize:(float)size color:(NSColor *)color type:(int)type;
-(void)setColor:(NSColor *)color;
-(void)setSize:(float)size;
-(void)setType:(int)type;
-(void)positionAtLineEndpoint:(NSPoint)aPoint withAngle:(float)angle;
//-(void)positionAtLineEndpoint:(NSPoint)aPoint previousPoint:(NSPoint)sourcePoint;
-(void)drawRect:(NSRect)rect;
@end

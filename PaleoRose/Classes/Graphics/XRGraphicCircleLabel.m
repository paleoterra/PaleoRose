//
//  XRGraphicCircleLabel.m
//  XRose
//
//  Created by Tom Moore on Fri Feb 13 2004.
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

#import "XRGraphicCircleLabel.h"
#import "XRGeometryController.h"
#import "math.h"

static NSString * const KVOKeyLabelAngle = @"labelAngle";
static NSString * const KVOKeyLabelFont = @"labelFont";

@interface XRGraphicCircleLabel()
@property (nonatomic, strong, nullable) NSMutableAttributedString *label;
@property (nonatomic, strong, nullable) NSAffineTransform *theTransform;
@property (readwrite) BOOL isCore;
@property (readwrite) NSPoint labelPoint;
@property (readwrite) NSSize labelSize;
@end

@implementation XRGraphicCircleLabel

-(instancetype)initCoreCircleWithController:(id<GraphicGeometrySource>)aController {
	if (!(self = [super initCoreCircleWithController:aController])) return nil;
	if(self) {
		self.showLabel = NO;
		_labelPoint = NSMakePoint(0.0,0.0);
		self.isPercent = [aController isPercent];
		_isCore = YES;
		self.percentSetting = 0.0;
		self.countSetting = 0;
		[self calculateGeometry];
        [self registerForKVO];
	}
	return self;
}

-(instancetype)initWithController:(id<GraphicGeometrySource>)controller {
	if (!(self = [super initWithController:controller])) return nil;
	if(self) {
		_showLabel = YES;
		_isCore = NO;
		_labelFont = [NSFont fontWithName:@"Arial-Black" size:12];
		_labelPoint = NSMakePoint(0.0,0.0);
        [self registerForKVO];
	}
	return self;
}

-(void)registerForKVO {
    NSArray *keys = @[KVOKeyLabelAngle, KVOKeyLabelFont];
    [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull keyPath, NSUInteger idx, BOOL * _Nonnull stop) {
        [self addObserver:self
               forKeyPath:keyPath
                  options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                  context:NULL];
    }];
}

-(void)computeLabelText {
	NSRange aRange;
	aRange.location = 0;
    self.isPercent = [self.geometryController isPercent];

	if(self.isPercent)
		_label = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%3.1f %c",(self.percentSetting * 100.0),'%']];
	else if(self.isFixedCount)
        _label = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%3.1f",(self.percentSetting * (float)[self.geometryController geometryMaxCount])]];
	else
		_label = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%i",self.countSetting]];

	aRange.length = [_label length];
	
	if(_labelFont)
		[_label setAttributes:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:_labelFont, self.strokeColor,nil]
														  forKeys:[NSArray arrayWithObjects:NSFontAttributeName,NSForegroundColorAttributeName,nil]] range:aRange];
}

-(void)computeTransform {
	self.theTransform = [NSAffineTransform transform];
	[self.theTransform rotateByDegrees:360.0-_labelAngle];
}

-(BOOL)drawClosedCircle {
    return !_showLabel || _isCore;
}

-(BOOL)circleBasedOnPercent {
    return [self.geometryController isPercent] || self.isFixedCount;
}

-(void)calculateGeometry
{
	[self computeLabelText];
	[self computeTransform];
    
    if([self drawClosedCircle]) {
        if([self circleBasedOnPercent]) {
            self.drawingPath = [NSBezierPath bezierPathWithOvalInRect:[self.geometryController circleRectForPercent:self.percentSetting]];
		}
		else {
            self.drawingPath = [NSBezierPath bezierPathWithOvalInRect:[self.geometryController circleRectForCount:self.countSetting]];
		}
	}
	else {
		float radius, angle;
        
        if([self circleBasedOnPercent]) {
            radius = [self.geometryController radiusOfPercentValue:self.percentSetting];
        }
		else {
            radius = [self.geometryController radiusOfCount:self.countSetting];
        }
        
        angle = [self.geometryController degreesFromRadians:atan((0.52*[_label size].width)/radius)];
        
		self.drawingPath = [NSBezierPath bezierPath];
		[self.drawingPath appendBezierPathWithArcWithCenter:NSMakePoint(0.0,0.0) radius:radius startAngle:90+angle endAngle:90-angle];
		_labelPoint = NSMakePoint(0 - (0.5*[_label size].width),radius - (0.5*[_label size].height));
	}
	[self.drawingPath setLineWidth:self.lineWidth];
}

-(void)drawRect:(NSRect)aRect {
    [self computeLabelText];
    if(NSIntersectsRect(aRect,[self.drawingPath bounds]))
    {  
        [NSGraphicsContext saveGraphicsState];

        [self.strokeColor set];

		[self.theTransform concat];
		[self.drawingPath stroke];
        if(self.drawsFill)
        {	
            [self.fillColor set];
            [self.drawingPath fill];
        }
        if((_showLabel)&&(!_isCore))
		{
			[_label drawAtPoint:_labelPoint];
		}
        [NSGraphicsContext restoreGraphicsState];
        [self setNeedsDisplay:NO];
    }
}

-(void)setGeometryPercent:(float)percent {
    self.percentSetting = percent*[self.geometryController geometryMaxPercent];
	[self calculateGeometry];
}

-(NSDictionary *)graphicSettings {
	NSMutableDictionary *parentDict = [NSMutableDictionary dictionaryWithDictionary:[super graphicSettings]];
    NSDictionary *classDict = @{
        XRGraphicKeyGraphicType : GraphicTypeLabelCircle,
        XRGraphicKeyShowLabel : [self stringFromBool:_showLabel],
        XRGraphicKeyLabelAngle : [self stringFromFloat:_labelAngle],
        XRGraphicKeyLabel : _label.string,
        XRGraphicKeyLabelFont : _labelFont,
        XRGraphicKeyIsCore : [self stringFromBool:_isCore],
    };
    [parentDict addEntriesFromDictionary:classDict];
	return parentDict;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    if ([keyPath isEqualToString: KVOKeyLabelAngle] || ([keyPath isEqualToString: KVOKeyLabelFont])) {
        [self calculateGeometry];
    }
}

@end

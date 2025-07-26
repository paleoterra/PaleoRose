//
//  XRGraphicLine.m
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

#import "XRGraphicLine.h"
#import "XRGeometryController.h"

static NSString * const KVOKeyTickType = @"tickType";
static NSString * const KVOKeyShowTick = @"showTick";
static NSString * const KVOKeyFont = @"font";
static NSString * const KVOKeySpokeAngle = @"spokeAngle";
static NSString * const KVOKeySpokePointOnly = @"spokePointOnly";
static NSString * const KVOKeySpokeNumberOrder = @"spokeNumberOrder";
static NSString * const KVOKeySpokeNumberCompassPoint = @"spokeNumberCompassPoint";

@interface XRGraphicLine()

@property (readwrite) float relativePercent;

-(void)setLineLabel;
-(void)calculateLabelTransform;
-(void)appendParallelTransform;
-(void)appendHorizontalTransform;

@end

@implementation XRGraphicLine
-(instancetype)initWithController:(id<GraphicGeometrySource>)aController {
    if (!(self = [super initWithController:aController])) return nil;
    if(self)
    {
        self.tickType = XRGraphicLineTickTypeNone;
        _relativePercent = 1.0;
        _spokeNumberAlign = XRGraphicLineNumberAlignHorizontal;
        _spokeNumberCompassPoint = XRGraphicLineNumberPoints;
        _spokeNumberOrder = XRGraphicLineNumberingOrderQuad;
        _showLabel = YES;
        _spokePointOnly = NO;
        self.font = [NSFont fontWithName:@"Arial-Black" size:12];
        [self registerForKVO];
        [self setLineLabel];
        [self calculateGeometry];
    }
    return self;
}

-(void)registerForKVO {
    NSArray *keys = @[KVOKeyTickType, KVOKeyShowTick, KVOKeyFont, KVOKeySpokeAngle, KVOKeySpokePointOnly, KVOKeySpokeNumberOrder, KVOKeySpokeNumberCompassPoint];
    [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull keyPath, NSUInteger idx, BOOL * _Nonnull stop) {
        [self addObserver:self
               forKeyPath:keyPath
                  options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                  context:NULL];
    }];
}

#pragma mark - Geometry Calculation

- (void)calculateGeometry {
    self.drawingPath = [[NSBezierPath alloc] init];
    
    // Draw the inner point of the line
    [self drawLineFromCenterToRadius:[self radiusForInnerPoint]];
    
    // Draw the outer point of the line with appropriate tick adjustment
    [self drawLineToOuterPoint];
    
    [self calculateLabelTransform];
}

- (void)drawLineFromCenterToRadius:(CGFloat)radius {
    NSPoint startPoint = [self pointAtRadius:radius angle:self.spokeAngle];
    [self.drawingPath moveToPoint:startPoint];
}

- (void)drawLineToOuterPoint {
    CGFloat radius = [self calculateOuterRadius];
    NSPoint endPoint = [self pointAtRadius:radius angle:self.spokeAngle];
    [self.drawingPath lineToPoint:endPoint];
}

- (CGFloat)calculateOuterRadius {
    if (self.tickType == XRGraphicLineTickTypeNone || !_showTick) {
        return [self.geometryController radiusOfRelativePercent:_relativePercent];
    } else if (self.tickType == XRGraphicLineTickTypeMinor) {
        return [self.geometryController unrestrictedRadiusOfRelativePercent:(_relativePercent + 0.05)];
    } else {
        return [self.geometryController unrestrictedRadiusOfRelativePercent:(_relativePercent + 0.1)];
    }
}

- (CGFloat)radiusForInnerPoint {
    return [self.geometryController radiusOfRelativePercent:0.0];
}

- (NSPoint)pointAtRadius:(CGFloat)radius angle:(CGFloat)angle {
    NSPoint point = NSMakePoint(0.0, radius);
    return [self.geometryController rotationOfPoint:point byAngle:angle];
}

#pragma mark - Label Handling

- (void)setLineLabel {
    // Reset showLabel flag
    _showLabel = YES;
    
    // Handle spoke point only mode
    if (_spokePointOnly) {
        // In point-only mode, show N/S/E/W for cardinal directions when in compass point mode
        if (_spokeNumberCompassPoint == XRGraphicLineNumberPoints) {
            // For compass point mode, only show N/S/E/W for exact cardinal directions
            if (self.spokeAngle == 0.0 || self.spokeAngle == 90.0 || 
                self.spokeAngle == 180.0 || self.spokeAngle == 270.0 || 
                self.spokeAngle == 360.0) {
                [self setCompassPointLabel];
                [self calculateLabelTransform];
                return;
            }
        } 
        // For non-compass point mode, show the angle value for cardinal directions
        else if (self.spokeAngle == 0.0 || self.spokeAngle == 90.0 || 
                self.spokeAngle == 180.0 || self.spokeAngle == 270.0 || 
                self.spokeAngle == 360.0) {
            [self setLabelForAngle:self.spokeAngle];
            [self calculateLabelTransform];
            return;
        }
        
        // For all other cases in point-only mode, show empty string
        _showLabel = NO;
        _lineLabel = [[NSMutableAttributedString alloc] initWithString:@""];
        [self calculateLabelTransform];
        return;
    }
    // Handle compass points (N/S/E/W) when in compass point mode
    else if (_spokeNumberCompassPoint == XRGraphicLineNumberPoints && 
             (self.spokeAngle == 0.0 || self.spokeAngle == 90.0 || 
              self.spokeAngle == 180.0 || self.spokeAngle == 270.0 || 
              self.spokeAngle == 360.0)) {
        [self setCompassPointLabel];
    }
    // Handle quadrant-based numbering
    else if (_spokeNumberOrder == XRGraphicLineNumberingOrderQuad) {
        [self setQuadrantBasedLabel];
    }
    // Handle 360-degree numbering
    else if (_spokeNumberOrder == XRGraphicLineNumberingOrder360) {
        [self setLabelForAngle:self.spokeAngle];
    }
    // Default case - show the angle as is
    else {
        [self setLabelForAngle:self.spokeAngle];
    }
    
    [self calculateLabelTransform];
}

- (void)setCompassPointLabel {
    NSString *compassPoint = @"N"; // Default
    
    if (self.spokeAngle == 0.0 || self.spokeAngle == 360.0) {
        compassPoint = @"N";
    } else if (self.spokeAngle == 90.0) {
        compassPoint = @"E";
    } else if (self.spokeAngle == 180.0) {
        compassPoint = @"S";
    } else if (self.spokeAngle == 270.0) {
        compassPoint = @"W";
    }
    
    _lineLabel = [[NSMutableAttributedString alloc] initWithString:compassPoint];
}

- (void)setQuadrantBasedLabel {
    double workAngle;
    
    if (self.spokeAngle <= 90.0) {
        workAngle = self.spokeAngle;
    }
    else if (self.spokeAngle <= 180.0) {
        workAngle = 180.0 - self.spokeAngle;
    }
    else if (self.spokeAngle <= 270.0) {
        workAngle = self.spokeAngle - 180.0;
    }
    else {
        workAngle = 360.0 - self.spokeAngle;
    }
    
    [self setLabelForAngle:workAngle];
}

- (void)setLabelForAngle:(double)angle {
    // Match the original behavior for integer vs. floating point display
    if (angle == floor(angle)) {
        _lineLabel = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", (int)angle]];
    } else {
        _lineLabel = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%3.1f", angle]];
    }
}


-(void)drawRect:(NSRect)aRect
{
    if(NSIntersectsRect(aRect,[self.drawingPath bounds])) {
        [NSGraphicsContext saveGraphicsState];

        [self.strokeColor set];
        //NSLog(@"width %f",[self.drawingPath lineWidth]);
        [self.drawingPath stroke];
        if(self.drawsFill) {
            [self.fillColor set];
            [self.drawingPath fill];
        }
        if(_showLabel) {

            [_labelTransform concat];
            [_lineLabel drawAtPoint:NSMakePoint(0.0,0.0)];
        }
        [NSGraphicsContext restoreGraphicsState];
        [self setNeedsDisplay:NO];
    }
}

-(void)calculateLabelTransform {
    NSRange labelRange;
    labelRange.location = 0;
    labelRange.length = [_lineLabel length];
    [_lineLabel setAttributes:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:self.font,self.strokeColor,nil]
                                                          forKeys:[NSArray arrayWithObjects:NSFontAttributeName,NSForegroundColorAttributeName,nil]] range:labelRange];
    _labelTransform = [NSAffineTransform transform];
    if(_spokeNumberAlign == XRGraphicLineNumberAlignHorizontal)
        [self appendHorizontalTransform];
    else
        [self appendParallelTransform];
}

-(void)appendHorizontalTransform {
    NSSize theSize = [_lineLabel size];
    float displacement = [self.geometryController unrestrictedRadiusOfRelativePercent:(_relativePercent + .2)];
    float rotationAngle;
    //step 1. shift to the center point
    [_labelTransform translateXBy:(-0.5*theSize.width) yBy:(-0.5*theSize.height)];
    //step 2. rotation in the inverse direction
    rotationAngle = self.spokeAngle - 90;

    [_labelTransform rotateByDegrees:(-1*rotationAngle)];

    //step 3. shift out
    [_labelTransform translateXBy:displacement yBy:0.0];

    //step 4. final rotation

    [_labelTransform rotateByDegrees:rotationAngle];
}

-(void)appendParallelTransform {

    NSSize theSize = [_lineLabel size];

    float displacement = [self.geometryController unrestrictedRadiusOfRelativePercent:(_relativePercent + 0.1)];
    float rotationAngle = 90-self.spokeAngle;
    //[_labelTransform translateXBy:(-0.5*theSize.width) yBy:(-0.5*theSize.height)];
    //transform 1.  Shift the text down by half the height.
    if((double)self.spokeAngle == 0.0)
    {
        [_labelTransform translateXBy:(-0.5*theSize.width) yBy:displacement];
    }
    else if((double)self.spokeAngle == 180.0)
        [_labelTransform translateXBy:(-0.5*theSize.width) yBy:(displacement+theSize.height)*-1];
    else
    {
        if(self.spokeAngle > 180.0)
        {
            [_labelTransform rotateByDegrees:rotationAngle-180];
            [_labelTransform translateXBy:-1 *(displacement+theSize.width) yBy:0.0];
            [_labelTransform translateXBy:0.0 yBy:(-0.5*theSize.height)];
        }
        else
        {

            [_labelTransform rotateByDegrees:rotationAngle];
            [_labelTransform translateXBy:displacement yBy:0.0];
            [_labelTransform translateXBy:0.0 yBy:(-0.5*theSize.height)];
        }
    }
}

-(NSDictionary *)graphicSettings {
    NSMutableDictionary *parentDict = [NSMutableDictionary dictionaryWithDictionary:[super graphicSettings]];
    NSDictionary *classDict = @{
        XRGraphicKeyGraphicType            : GraphicTypeLine,
        XRGraphicKeyRelativePercent        : [self stringFromFloat:  _relativePercent],
        XRGraphicKeyAngleSetting           : [self stringFromFloat: self.spokeAngle],
        XRGraphicKeyTickType               : [self stringFromInt: _tickType],
        XRGraphicKeyShowTick               : [self stringFromBool:_showTick],
        XRGraphicKeySpokeNumberAlignment   : [self stringFromInt: _spokeNumberAlign],
        XRGraphicKeySpokeNumberCompassPoint: [self stringFromInt: _spokeNumberCompassPoint],
        XRGraphicKeySpokeNumberOrder       : [self stringFromInt: _spokeNumberOrder],
        XRGraphicKeyShowLabel              : [self stringFromBool:_showLabel],
        XRGraphicKeyLineLabel              : _lineLabel ?: @"",
        XRGraphicKeyCurrentFont            : self.font ?: [NSFont systemFontOfSize:[NSFont systemFontSize]]
    };
    [parentDict addEntriesFromDictionary:classDict];
    return parentDict;
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    [super observeValueForKeyPath:keyPath
                         ofObject:object
                           change:change
                          context:context];
    if ([keyPath isEqualToString: KVOKeyTickType] || [keyPath isEqualToString: KVOKeyShowTick] || [keyPath isEqualToString: KVOKeyFont]) {
        [self calculateGeometry];
    } else if ([keyPath isEqualToString: KVOKeySpokeAngle] || [keyPath isEqualToString: KVOKeySpokePointOnly] ||
               [keyPath isEqualToString: KVOKeySpokeNumberCompassPoint] || [keyPath isEqualToString: KVOKeySpokeNumberOrder]) {
        [self setLineLabel];
        [self calculateGeometry];
    }
}

@end

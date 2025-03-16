//
//  XRLayerGrid.h
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
#import "XRLayer.h"

#define XRLayerGridDefaultRingCount  @"XRLayerGridDefaultRingCount"
#define XRLayerGridDefaultSpokeCount @"XRLayerGridDefaultSpokeCount"
#define XRLayerGridDefaultSpokeAngle @"XRLayerGridDefaultSpokeAngle"
#define XRLayerGridDefaultRingPercent @"XRLayerGridDefaultRingPercent"
#define XRLayerGridDefaultRingFixedCount @"XRLayerGridDefaultRingFixedCount"
#define XRLayerGridDefaultSectorLock @"XRLayerGridDefaultSectorLock"
#define XRLayerGridDefaultRingFixed @"XRLayerGridDefaultRingFixed"
#define XRLayerGridDefaultLineWidth @"XRLayerGridDefaultLineWidth"
@class XRLayer,XRGraphicLine;

@interface XRLayerGrid : XRLayer {
	int _spokeCount;

	float _spokeAngle;
	
	//working with rings
	BOOL _fixedCount;
	BOOL _ringsVisible;
	int _fixedRingCount;
	int _ringCountIncrement;
	float _ringPercentIncrement;
	BOOL _showRingLabels;
	float _labelAngle;
	NSFont *_ringFont;
	//workingWithSpokes
	BOOL _spokeSectorLock;
	BOOL _spokesVisible;
	BOOL _isPercent;
	//tick marks
	BOOL _showTicks;
	BOOL _minorTicks;
	//line labels
	BOOL _showLabels;
	BOOL _pointsOnly;
	int _spokeNumberAlign;
	int _spokeNumberCompassPoint;
	int _spokeNumberOrder;
	NSFont *_spokeFont;
	
}

-(id)initWithGeometryController:(XRGeometryController *)aController;
-(id)initWithGeometryController:(XRGeometryController *)aController dictionary:(NSDictionary *)configure;

-(id)initWithIsVisible:(BOOL)visible
              active:(BOOL)active
               biDir:(BOOL)isBiDir
                name:(NSString *)layerName
          lineWeight:(float)lineWeight
            maxCount:(int)maxCount
            maxPercent:(float)maxPercent
           strokeColor:(NSColor *)strokeColor
             fillColor:(NSColor *)fillColor
          isFixedCount:(BOOL)isFixedCount
          ringsVisible:(BOOL)ringsVisible
        fixedRingCount:(int)fixedRingCount
    ringCountIncrement:(int)ringCountIncrement
ringPercentIncrement:(float)ringPercentIncrement
        showRingLabels:(BOOL)showRingLabels
            labelAngle:(float)labelAngle
              ringFont:(NSFont *)ringFont
          radialsCount:(int)radialsCount
          radialsAngle:(float)radialsAngle
 radialsLabelAlignment:(int)radialsLabelAlignment
   radialsCompassPoint:(int)radialsCompassPoint
          radialsOrder:(int)radialsOrder
            radialFont:(NSFont *)radialFont
     radialsSectorLock:(BOOL)sectorLock
        radialsVisible:(BOOL)radialsVisible
      radialsIsPercent:(BOOL)isPercent
          radialsTicks:(BOOL)radialTicks
     radialsMinorTicks:(BOOL)radialMinorTicks
          radialLabels:(BOOL)radialLabels;

-(void)setSpokeCount:(int)newCount;
-(void)setSpokeAngle:(float)newAngle;
-(int)spokeCount;
-(float)spokeAngle;
-(BOOL)fixedCount;
-(void)setFixedCount:(BOOL)isFixed;
-(BOOL)spokeSectorLock;
-(void)setSpokeSectorLock:(BOOL)sectorLock;
-(BOOL)spokeSectorsEditable;
-(void)addFixedSpokes;
-(void)addVariableSpokes;
-(void)configureLine:(XRGraphicLine *)aLine;
-(void)addVariableRings;
-(void)addFixedRings;

-(void)spokeAngleDidChange;
-(void)spokeCountDidChange;
-(void)setSpokeFont:(NSFont *)font;
-(NSFont *)spokeFont;
-(void)setRingFont:(NSFont *)font;
-(NSFont *)ringFont;
-(BOOL)showLabels;
-(int)fixedRingCount;
-(BOOL)ringsVisible;
-(int)ringCountIncrement;
-(float)ringPercentIncrement;
-(float)ringLabelAngle;
-(NSString *)ringFontName;
-(float)ringFontSize;
-(int)radialsCount;
-(float)radialsAngle;
-(int)radialsLabelAlign;
-(int)radialsCompassPoint;
-(int)radiansOrder;
-(NSString *)radianFontName;
-(float)radianFontSize;
-(BOOL)radianSectorLock;
-(BOOL)radianVisible;
-(BOOL)radianIsPercent;
-(BOOL)radianTicks;
-(BOOL)radianMintoTicks;
-(BOOL)radianLabels;

-(LITMXMLTree *)xmlTreeForVersion1_0Rings;
-(LITMXMLTree *)xmlTreeForVersion1_0Radials;

-(id)initWithGeometryController:(XRGeometryController *)aController xmlTree:(LITMXMLTree *)configureTree forVersion:(NSString *)version;
-(void)configureWithXMLTree:(LITMXMLTree *)configureTree version:(NSString *)version;
-(void)configureWithXMLTree1_0:(LITMXMLTree *)configureTree;
-(void)configureRingsWithXMLTree:(LITMXMLTree *)configureTree version:(NSString *)version;
-(void)configureRingsWithXMLTree1_0:(LITMXMLTree *)configureTree;
-(void)configureRadialsWithXMLTree:(LITMXMLTree *)configureTree version:(NSString *)version;
-(void)configureRadialsWithXMLTree1_0:(LITMXMLTree *)configureTree;

@end

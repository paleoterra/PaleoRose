//
// MIT License
//
// Copyright (c) 2005 to present Thomas L. Moore.
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

#import "XRoseView.h"
#import "XRGeometryController.h"
#import "XRLayerText.h"
#import "XRoseWindowController.h"
#import <PaleoRose-Swift.h>

@implementation XRoseView

- (id)initWithFrame:(NSRect)frameRect {
	if ((self = [super initWithFrame:frameRect]) != nil) {
		// Add initialization code here
		[self setPostsFrameChangedNotifications:YES];
        [self registerForDraggedTypes:[NSArray arrayWithObject:NSPasteboardTypeTIFF]];
	}
	return self;
}

-(void)setFrame:(NSRect)frame {
	[super setFrame:frame];
	[self resetDrawingFrames];
}

-(void)awakeFromNib {
	[self computeDrawingFrames];
}

- (void)drawRect:(NSRect)rect {
	[self.roseTableController drawRect:rect];
}

-(void)resetDrawingFrames {
	if(NSEqualRects([self frame],_lastFrame))
		return;
	else {
		[self computeDrawingFrames];
	}
}

-(void)computeDrawingFrames {
	NSRect newBounds;

	//set last frame
	_lastFrame = [self frame];

	//do work here
	//estimate internal rect
	_drawingRect = _lastFrame;
	if(_lastFrame.size.width>_lastFrame.size.height) {
	//sets the width to be smaller
	_drawingRect.size.width = _lastFrame.size.height;
	} else {
	//sets the width to be smaller
	_drawingRect.size.height = _lastFrame.size.width;
	}

	//reset bounds to center the _drawingRect in the view
	newBounds.size = _lastFrame.size;//size has to be fixed by the frame
	newBounds.origin.x = -1 * (_lastFrame.size.width / 2.0);
	newBounds.origin.y = -1 * (_lastFrame.size.height / 2.0);
	[self setBounds:newBounds];
	//bounds are now reset.  Reset the origin of the _drawingRect
	_drawingRect.origin.x = -1 * (_drawingRect.size.width / 2.0);
	_drawingRect.origin.y = -1 * (_drawingRect.size.height / 2.0);

	//post notification that the drawing rect has changed
	if (self.rosePlotController) {
		[self.rosePlotController resetGeometryWithBoundsRect:_drawingRect];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:XRRoseViewDrawingRectDidChange object:self];
}

- (void)mouseDown:(NSEvent *)theEvent {
	XRLayer *aLayer;
	LayersTableController *tableController = (LayersTableController *)self.roseTableController;
    if(([theEvent type] == NSEventTypeLeftMouseDown)&&([theEvent clickCount]>1))
	   [tableController handleMouseEvent:theEvent];
    else if((aLayer = [tableController activeLayerWith:[self convertPoint:[theEvent locationInWindow] fromView:nil]])&&([theEvent type]==NSEventTypeLeftMouseDown)) {
		NSImage *dragImage = [(XRLayerText *)aLayer dragImage];
        [[NSPasteboard pasteboardWithName:NSPasteboardNameDrag] setData:[dragImage TIFFRepresentation] forType:NSPasteboardTypeTIFF];
		draggedObject = aLayer;
		[self dragImage:dragImage
					 at:[(XRLayerText *)aLayer imageBounds].origin
				 offset:NSMakeSize(0.0,0.0) 
				  event:theEvent 
             pasteboard:[NSPasteboard pasteboardWithName:NSPasteboardNameDrag]
				 source:self
			  slideBack:NO];
    } else {
        [tableController handleMouseEvent:theEvent];
    }
	//if([theEvent type] == NSLeftMouseDown)
	//{
	//	NSPoint aPoint =[self convertPoint:[theEvent locationInWindow] fromView:self];
	//	[_roseTableController detectLayerHitAtPoint:aPoint];
	//}
    	
    return;
}

-(void)copyPDFToPasteboard {
	NSData *data = [self dataWithPDFInsideRect:[self bounds]];
	
    [[NSPasteboard generalPasteboard]  declareTypes:[NSArray arrayWithObjects:NSPasteboardTypePDF,nil] owner:self];
    [[NSPasteboard generalPasteboard] setData:data forType:NSPasteboardTypePDF];
}

-(void)copyTIFFToPastboard {
	NSData *data = [self dataWithPDFInsideRect:[self bounds]];
	NSImage *anImage = [[NSImage alloc] initWithSize:[self bounds].size];
    [[NSPasteboard generalPasteboard]  declareTypes:[NSArray arrayWithObjects:NSPasteboardTypeTIFF,nil] owner:self];
	[anImage addRepresentation:[NSPDFImageRep imageRepWithData:data]];
    [[NSPasteboard generalPasteboard] setData:[anImage TIFFRepresentationUsingCompression:NSTIFFCompressionNone factor:1.0] forType:NSPasteboardTypeTIFF];
}

#pragma mark - printing

- (BOOL)knowsPageRange:(NSRangePointer)range {
    NSRect bounds = [self bounds];
    float printHeight = [self calculatePrintHeight];
	
    range->location = 1;
    range->length = NSHeight(bounds) / printHeight + 1;
    return YES;
}


- (NSRect)rectForPage:(int)page {
    NSRect bounds = [self bounds];

	return bounds;
}


- (float)calculatePrintHeight {
    // Obtain the print info object for the current operation
    NSPrintInfo *pi = [[NSPrintOperation currentOperation] printInfo];
	
    // Calculate the page height in points
    NSSize paperSize = [pi paperSize];
    float pageHeight = paperSize.height - [pi topMargin] - [pi bottomMargin];
	
    // Convert height to the scaled view 
    float scale = [[[pi dictionary] objectForKey:NSPrintScalingFactor]
		floatValue];
    return pageHeight / scale;
}

#pragma mark dragging

- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal {

	//NSLog(@"draggingSourceOperationMaskForLocal");
	if(draggedObject)
	{
		//NSLog(@"generic");
		[[NSPasteboard pasteboardWithName:NSDragPboard] declareTypes:[NSArray arrayWithObject:NSTIFFPboardType] owner:self];
		[[NSPasteboard pasteboardWithName:NSDragPboard] setData:[[draggedObject dragImage] TIFFRepresentation] forType:NSTIFFPboardType];

		return NSDragOperationMove;
	}
	return NSDragOperationNone;
}

- (unsigned int)dragOperationForDraggingInfo:(id <NSDraggingInfo>)sender {
    if([sender draggingSource]==self)
		return NSDragOperationMove;
	else
		return NSDragOperationNone;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    return [self dragOperationForDraggingInfo:sender];
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender {
    return [self dragOperationForDraggingInfo:sender];
}

- (void)draggingExited:(id <NSDraggingInfo>)sender {
    return;
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender {
	if([sender draggingSource]==self)
		return YES;
    return NO;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    return YES;
}

 - (void)concludeDragOperation:(id <NSDraggingInfo>)sender {
    NSPoint draggedImageLocation = [self convertPoint:[sender draggedImageLocation] fromView:nil];
	[(XRLayerText *)draggedObject moveToPoint:draggedImageLocation];
	draggedObject = nil;
}

-(NSData *)imageDataForType:(NSString *)type {
	if(([type isEqualToString:@"PDF"])||([type isEqualToString:@"pdf"])) {
		return [self dataWithPDFInsideRect:[self bounds]];
	} else if(([type isEqualToString:@"TIF"])||([type isEqualToString:@"tif"])) {
		NSData *data = [self dataWithPDFInsideRect:[self bounds]];
		NSImage *anImage = [[NSImage alloc] initWithSize:[self bounds].size];

		[anImage addRepresentation:[NSPDFImageRep imageRepWithData:data]];
		
		return [anImage TIFFRepresentationUsingCompression:NSTIFFCompressionNone factor:1.0];
	} else if(([type isEqualToString:@"JPG"])||([type isEqualToString:@"jpg"])) {
		NSImage *anImage = [[NSImage alloc] initWithSize:[self bounds].size];
		NSAffineTransform *aTrans = [NSAffineTransform transform] ;
		[aTrans translateXBy:([self bounds].size.width)/2.0 yBy:([self bounds].size.height)/2.0] ;
		[anImage lockFocus];
		[[NSColor whiteColor] set];
		[[NSBezierPath bezierPathWithRect:NSMakeRect(0,0,[self bounds].size.width,[self bounds].size.height)] fill];
		[aTrans set];
		[self drawRect:[self bounds]];
		[anImage unlockFocus];
        return [[NSBitmapImageRep imageRepWithData:[anImage TIFFRepresentationUsingCompression:NSTIFFCompressionNone factor:1.0]]representationUsingType:NSBitmapImageFileTypeJPEG properties:[NSDictionary
dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:1.0],NSImageCompressionFactor, nil]];
	}
	return nil;
}


@end

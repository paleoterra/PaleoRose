//
//  XRLayerText.m
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

#import "XRLayerText.h"
#import "XRLayer.h"
#import "XRGeometryController.h"
#import "XRoseView.h"
#import "sqlite3.h"
#import "XRoseWindowController.h"
#import "LITMXMLBinaryEncoding.h"

static NSLayoutManager *sharedDrawingLayoutManager(void);

@implementation XRLayerText
-(id)initWithGeometryController:(XRGeometryController *)aController parentView:(NSView *)view
{
    if (!(self = [super initWithGeometryController:aController])) return nil;
    if(self)
    {

        _contents = [[NSTextStorage  alloc] init];
        gutter = 4.0;
        [aController calculateRelativePositionWithPoint:textBounds.origin intoRadius:&estimatedRadius intoAngle:&estimatedAngle];
        [self setLayerName:@"Default Text"];
        [self setContents:@"Text"];

        textBounds.origin = NSMakePoint(0.0,0.0);
        textBounds.size = [_contents size];
        //NSLog(@"bounds %@",NSStringFromRect(textBounds));
    }
    return self;
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
              contents:(NSAttributedString *)contents
           rectOriginX:(float)rectOriginX
           rectOriginY:(float)rectOriginY
            rectHeight:(float)rectHeight
             rectWidth:(float)rectWidth {
    textBounds = NSMakeRect(
                            rectOriginX,
                            rectOriginY,
                            rectWidth,
                            rectHeight
                            );
    self = [super init];
    if (self) {
        _contents = [[NSTextStorage  alloc] init];
        gutter = 4.0;
        [self setLayerName:@"Default Text"];
        [self setContents:@"Text"];

        _isVisible = visible;
        _isActive = active;
        _isBiDir = isBiDir;
        _layerName = layerName;
        _lineWeight = lineWeight;
        _maxCount = maxCount;
        _maxPercent = maxPercent;
        _strokeColor = strokeColor;
        _fillColor = fillColor;
        [self setContents:contents];
        textBounds = NSMakeRect((CGFloat)rectOriginX, (CGFloat)rectOriginY, (CGFloat)rectWidth, (CGFloat)rectHeight);
//        [self setContents:[[NSAttributedString alloc] initWithData:decodeBase64([[NSString alloc] initWithData:contents encoding:NSUTF8StringEncoding]) options:@{} documentAttributes:nil error:nil ]];
    }
    return self;
}

- (void)setContents:(id)contents
{
    //NSLog(@"length2 %@",contents);
    if(_contents != contents)
    {

        if([contents isKindOfClass:[NSString class]])
            [_contents replaceCharactersInRange:NSMakeRange(0,[_contents length]) withString:contents];
        else
            [_contents replaceCharactersInRange:NSMakeRange(0,[_contents length]) withAttributedString:contents];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:self];
}

-(NSString *)encodedContents {
    NSRange aRange;
    aRange.location = 0;
    aRange.length = [_contents length];
    return encodeBase64([_contents RTFFromRange:aRange documentAttributes:@{}]);
}

-(NSRect)textRect {
    return textBounds;
}

- (NSTextStorage *)contents
{
    return _contents;
}

static NSLayoutManager *sharedDrawingLayoutManager(void) {
    // This method returns an NSLayoutManager that can be used to draw the contents of a SKTTextArea.
    static NSLayoutManager *sharedLM = nil;
    if (!sharedLM) {
        NSTextContainer *tc = [[NSTextContainer allocWithZone:NULL] initWithContainerSize:NSMakeSize(1.0e6, 1.0e6)];

        sharedLM = [[NSLayoutManager allocWithZone:NULL] init];

        [tc setWidthTracksTextView:NO];
        [tc setHeightTracksTextView:NO];
        [sharedLM addTextContainer:tc];
    }
    return sharedLM;
}

-(void)drawRect:(NSRect)rect
{
    if (([_contents length] > 0) && (_isVisible) && (tempView == nil)){
        NSRect drawRect;
        /*NSLayoutManager *lm = sharedDrawingLayoutManager();
         NSTextContainer *tc = [[lm textContainers] lastObject];
         if(tc)
         NSLog(@"we have tc");
         if(lm)
         NSLog(@"we have lm");
         NSRange glyphRange;

         //[tc setContainerSize:textBounds.size];


         [contents addLayoutManager:lm];
         // Force layout of the text and find out how much of it fits in the container.
         glyphRange = [lm glyphRangeForTextContainer:tc];
         NSLog(@"here %@",NSStringFromRange(glyphRange));
         if (glyphRange.length > 0) {
         [lm drawBackgroundForGlyphRange:glyphRange atPoint:textBounds.origin];
         NSLog(@"draw");
         [[self strokeColor] set];
         [lm drawGlyphsForGlyphRange:glyphRange atPoint:textBounds.origin];
         }
         [contents removeLayoutManager:lm];*/
        drawRect = textBounds;
        //NSLog(@"text bounds");
        //NSLog(NSStringFromRect(textBounds));
        drawRect.size.width += gutter;
        drawRect.size.height += gutter;
        drawRect.origin.y -= 0.5 * gutter;
        [_contents drawInRect:drawRect];
    }
}

-(BOOL)handleMouseEvent:(NSEvent *)anEvent
{
    //NSLog(@"handleMouseEvent");
    //	if([anEvent type] == NSLeftMouseDragged)
    //	{
    //		int i = 1;
    //		i++;
    //	}
    //	else
    if ([anEvent type] == NSEventTypeLeftMouseDown)
    {
        if([anEvent clickCount] == 2)
            [self displayTextFieldForEditing:anEvent];
        else if(tempView)
            [self removeTextFieldAfterEditing:anEvent];
    }
    return NO;
}

-(BOOL)hitDetection:(NSPoint)testPoint
{
    //NSLog(@"point %@",NSStringFromPoint(testPoint));
    //NSLog(@"rect %@",NSStringFromRect(textBounds));
    return  NSMouseInRect(testPoint,textBounds,NO);

}
-(NSRect)imageBounds
{
    NSRect bounds  = textBounds;
    bounds.size = NSMakeSize(textBounds.size.width + gutter,textBounds.size.height + gutter);
    bounds.origin.y -= 0.5*gutter;
    return bounds;
}

-(NSImage *)dragImage
{

    NSRect imageRect = textBounds;
    imageRect.origin = NSMakePoint(0.0,0.0);
    imageRect.size.width += gutter;
    imageRect.size.height += gutter;

    NSImage *image = [[NSImage alloc] initWithSize:imageRect.size];

    [image lockFocus];
    //NSLog(@"length4");
    if ([_contents length] > 0) {
        /*NSLayoutManager *lm = sharedDrawingLayoutManager();
         NSTextContainer *tc = [[lm textContainers] objectAtIndex:0];
         if(tc)
         NSLog(@"we have tc");
         if(lm)
         NSLog(@"we have lm");
         NSRange glyphRange;

         //[tc setContainerSize:textBounds.size];


         [contents addLayoutManager:lm];
         // Force layout of the text and find out how much of it fits in the container.
         glyphRange = [lm glyphRangeForTextContainer:tc];
         NSLog(@"here %@",NSStringFromRange(glyphRange));
         if (glyphRange.length > 0) {
         [lm drawBackgroundForGlyphRange:glyphRange atPoint:NSMakePoint(0.0,0.0)];
         NSLog(@"draw");
         [[self strokeColor] set];
         [lm drawGlyphsForGlyphRange:glyphRange atPoint:NSMakePoint(0.0,0.0)];
         }
         [contents removeLayoutManager:lm];*/

        [_contents drawInRect:imageRect];
    }
    [image unlockFocus];
    return image;
}

-(void)moveToPoint:(NSPoint)newPoint
{
    //NSLog(@"moveToPoint:");
    //NSLog(NSStringFromPoint(newPoint));
    //NSLog(NSStringFromRect(textBounds));

    textBounds.origin = newPoint;
    //NSLog(NSStringFromRect(textBounds));
    [geometryController calculateRelativePositionWithPoint:textBounds.origin intoRadius:&estimatedRadius intoAngle:&estimatedAngle];
    //NSLog(@"endMoveToPoint:");
    [[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:self];
}

-(void)generateGraphics
{
    NSPoint newOrigin = [geometryController rotationOfPoint:NSMakePoint([geometryController unrestrictedRadiusOfRelativePercentNoCore:estimatedRadius],0.0) byAngle:estimatedAngle];
    textBounds.origin = newOrigin;
    //NSLog(NSStringFromPoint(newOrigin));
    //NSLog(@"result %f %f",[geometryController unrestrictedRadiusOfRelativePercentNoCore:estimatedRadius],estimatedRadius);
}

-(void)displayTextFieldForEditing:(NSEvent *)theEvent
{
    //NSLog(@"displayTextFieldForEditing");
    NSRange theRange,theRange2;
    NSRect gutteredRect = textBounds;
    //NSTextStorage *contents = [self contents];
    NSLayoutManager *lm = sharedDrawingLayoutManager();

    /*working with the gutter*/
    gutteredRect.origin.x = textBounds.origin.x - gutter;
    gutteredRect.size.width += 2 * gutter;


    NSTextView *theField = [[NSTextView alloc] initWithFrame:gutteredRect];
    theRange.location = 0;
    //NSLog(@"length5");
    theRange.length = [_contents length];
    theRange2.location = 0;
    //NSLog(@"length1");
    theRange2.length = [[theField string] length];
    [theField setContinuousSpellCheckingEnabled:YES];
    //[theField setConstrainedFrameSize:NSMakeSize(1000.0,1000.0)];
    [theField setDelegate:self];
    [theField setHorizontallyResizable:YES];
    [theField setVerticallyResizable:YES];
    [theField setMinSize:NSMakeSize(20.0,15.0)];
    [theField setMaxSize:NSMakeSize(1000.0,1000.0)];
    //[theField setAutoresizingMask:(NSViewNotSizable)];
    [theField replaceTextContainer:[[lm textContainers] lastObject]];
    [theField replaceCharactersInRange:theRange2 withRTF:[_contents RTFFromRange:theRange documentAttributes:@{}]];
    tempView = theField;
    [tempView setNeedsDisplay:YES];
    [[(XRoseWindowController *)[[theEvent window] windowController] mainView] addSubview:theField];
}

-(void)removeTextFieldAfterEditing:(NSEvent *)theEvent
{
    //NSLog(@"removeTextFieldAfterEditing");
    NSRect gutterRect;
    NSLayoutManager *theManager = [tempView layoutManager];
    [self setContents:[theManager attributedString]];
    gutterRect = [tempView frame];
    textBounds = gutterRect;
    textBounds.origin.x += gutter;
    textBounds.size.width -= 2 * gutter;
    [tempView removeFromSuperview];
    [tempView setDelegate:nil];
    [tempView removeFromSuperview];
    tempView = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:self];

}

- (void)textDidChange:(NSNotification *)aNotification
{
    //NSLog(@"textViewDidChangeTypingAttributes");

    NSRect frame = [tempView frame];
    frame.origin.y = textBounds.origin.y - (frame.size.height - textBounds.size.height);
    [tempView setFrame:frame];
    [[NSNotificationCenter defaultCenter] postNotificationName:XRLayerRequiresRedraw object:self];
}

+(NSString *)classTag
{
    return @"TEXT";
}

-(NSString *)type
{
    return @"XRLayerText";
}

-(void)saveToSQLDB:(sqlite3 *)db layerID:(int)layerID
{
    NSMutableString *command= [[NSMutableString alloc] init];
    int error;
    char *errorMsg;
    //NSAttributedString *tempString = [[NSAttributedString alloc] initWithAttributedString:_contents];
    NSRange aRange;
    aRange.location = 0;
    aRange.length = [_contents length];
    [super saveToSQLDB:db layerID:layerID];

    [command appendString:@"INSERT INTO _layerText (LAYERID,CONTENTS,RECT_POINT_X,RECT_POINT_Y,RECT_SIZE_HEIGHT,RECT_SIZE_WIDTH) "];
    [command appendFormat:@"VALUES (%i,\"%@\",%f,%f,%f,%f) ",layerID,encodeBase64([_contents RTFFromRange:aRange documentAttributes:@{}]),textBounds.origin.x,textBounds.origin.y,textBounds.size.height,textBounds.size.width];
    error = sqlite3_exec(db,[command UTF8String],nil,nil,&errorMsg);
    if(error!=SQLITE_OK)
        NSLog(@"error: %s",errorMsg);



}

-(id)initWithGeometryController:(XRGeometryController *)aController sqlDB:(sqlite3 *)db   layerID:(int)layerID withParentView:(NSView *)parentView
{
    if (!(self = [self initWithGeometryController:aController parentView:parentView])) return nil;
    if(self)
    {
        [super configureWithSQL:db forLayerID:layerID];
        [self configureWithSQL:db forLayerID:layerID];
    }
    return self;
}

-(void)configureWithSQL:(sqlite3 *)db forLayerID:(int)layerid
{
    int columns;
    sqlite3_stmt *stmt;
    NSString *columnName;
    const char *pzTail;
    NSRect aTextRect;
    NSAttributedString *tempString;
    NSString *command = [NSString stringWithFormat:@"SELECT * FROM _layerText WHERE LAYERID=%i",(int)layerid];
    //NSLog(@"Configuring with SQL");
    sqlite3_prepare(db,[command UTF8String],-1,&stmt,&pzTail);
    while(sqlite3_step(stmt)==SQLITE_ROW)
    {
        columns = sqlite3_column_count(stmt);
        for(int i=0;i<columns;i++)
        {
            columnName = [NSString stringWithUTF8String:(char *)sqlite3_column_name(stmt,i)];
            if([columnName isEqualToString:@"RECT_POINT_X"])
            {
                aTextRect.origin.x =  (float)sqlite3_column_double(stmt,i);

            }
            else if([columnName isEqualToString:@"RECT_POINT_Y"])
            {
                aTextRect.origin.y =  (float)sqlite3_column_double(stmt,i);

            }
            else if([columnName isEqualToString:@"RECT_SIZE_HEIGHT"])
            {
                aTextRect.size.height =  (float)sqlite3_column_double(stmt,i);

            }
            else if([columnName isEqualToString:@"RECT_SIZE_WIDTH"])
            {
                aTextRect.size.width =  (float)sqlite3_column_double(stmt,i);

            }
            else if([columnName isEqualToString:@"CONTENTS"])
            {
                tempString = [[NSAttributedString alloc] initWithData:decodeBase64([NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt,i)]) options:@{} documentAttributes:nil error:nil ];
            }



        }
    }
    [self setContents:tempString];
    textBounds = aTextRect;

}

@end

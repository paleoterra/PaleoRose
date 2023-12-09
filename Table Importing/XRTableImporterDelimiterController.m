//
// MIT License
//
// Copyright (c) 2006 to present Thomas L. Moore.
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
#import "XRTableImporterDelimiterController.h"

@implementation XRTableImporterDelimiterController
//
//+ (void)initialize {
//    [XRTableImporterDelimiterController setKeys:
//        [NSArray arrayWithObjects:@"delimiterPopup", nil]
//        triggerChangeNotificationsForDependentKey:@"activateDelimiterField"];
//}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    
    if ([key isEqualToString:@"activateDelimiterField"]) {
        NSArray *affectingKeys = @[@"delimiterPopup"];
        keyPaths = [keyPaths setByAddingObjectsFromArray:affectingKeys];
    }
    return keyPaths;
}

-(id)initWithPath:(NSString *)aPath
{

	if (!(self = [super init])) return nil;

	if(self)
	{
        [[NSBundle mainBundle] loadNibNamed:@"XRTableInitialTextController"
                         owner:self
               topLevelObjects:nil];
		if(aPath)
			[self setValue:[[aPath lastPathComponent] stringByDeletingPathExtension] forKeyPath:@"tableName"];
		else
			[self setValue:@"Untitled_Table" forKeyPath:@"tableName"];
		[self setValue:@", " forKeyPath:@"delimiterFieldValue"];
        [self setValue:[NSNumber numberWithInt:NSControlStateValueOn] forKeyPath:@"columnTitles"];
		
	}
	
	return self;
}

- (IBAction)cancelImport:(id)sender
{
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseCancel];
}

- (IBAction)import:(id)sender
{
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseOK];
}

-(BOOL)activateDelimiterField
{
	if(delimiterPopup>0)
		return YES;
	else
		return NO;
}

-(NSWindow *)window
{
	return window;
}

-(NSDictionary *)results
{
	NSMutableDictionary *theDict = [[NSMutableDictionary alloc] init];

	[theDict setObject:[self valueForKeyPath:@"tableName"] forKey:@"tableName"];
	[theDict setObject:[self valueForKeyPath:@"columnTitles"] forKey:@"columnTitles"];
	[theDict setObject:[self valueForKeyPath:@"delimiterPopup"] forKey:@"delimiterPopup"];
	[theDict setObject:[self valueForKeyPath:@"delimiterFieldValue"] forKey:@"delimiterFieldValue"];
	
	switch([[self valueForKeyPath:@"encodingValue"] intValue])
	{
		case 0:
			[theDict setObject:[NSNumber numberWithInt:NSASCIIStringEncoding] forKey:@"encodingValue"];
			break;
		case 1:
			[theDict setObject:[NSNumber numberWithInt:NSMacOSRomanStringEncoding] forKey:@"encodingValue"];
			break;
		case 2:
			[theDict setObject:[NSNumber numberWithInt:NSWindowsCP1254StringEncoding] forKey:@"encodingValue"];
			break;
		case 3:
			[theDict setObject:[NSNumber numberWithInt:NSUTF8StringEncoding] forKey:@"encodingValue"];
			break;
		case 4:
			[theDict setObject:[NSNumber numberWithInt:NSISOLatin1StringEncoding] forKey:@"encodingValue"];
			break;
		case 5:
			[theDict setObject:[NSNumber numberWithInt:NSISOLatin2StringEncoding] forKey:@"encodingValue"];
			break;
		default:
			[theDict setObject:[NSNumber numberWithInt:NSASCIIStringEncoding] forKey:@"encodingValue"];
			break;
	}
	//NSLog([theDict description]);
	return [NSDictionary dictionaryWithDictionary:theDict];
}


@end

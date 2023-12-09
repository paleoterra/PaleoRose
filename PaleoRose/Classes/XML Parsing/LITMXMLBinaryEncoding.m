//
//  LITMXMLBinaryEncoding.m
//  LITMAppKit
//
//  Created by Tom Moore on Sun Nov 09 2003.
//
// MIT License
//
// Copyright (c) 2003 to present Thomas L. Moore.
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

#import "LITMXMLBinaryEncoding.h"

NSString * encodeBase16(NSData * data)
{
    static char base16lc[] = {"0123456789abcdef"};
    
    NSData *theDataObject;
    NSMutableString *finalString = [[NSMutableString alloc] init];
    int i;
    int count = (int)[data length];
    int groups = count * 2 / 80;
    NSRange aRange;
    char *theChars = (char *)malloc(sizeof(char) * count * 2);
    unsigned char *theData = (unsigned char *)malloc(sizeof(unsigned char) * count);

    //NSLog(@"data length %i",[data length]);
    [data getBytes:theData length:sizeof(unsigned char) * count];
    
    for(i=0;i<count;i++)
    {
        unsigned p;
        p = (theData[i] >> 4) & 0x0F;//shift the byte by 4 bits and mask out first 4 bits
        theChars[(i*2)] = base16lc[p];
        p = theData[i] & 0x0F;//mask out first 4 bits
        theChars[(i*2)+1] = base16lc[p];
        //NSLog(@"%i %c %c",i,theChars[(i*2)],theChars[(i*2)+1]);
    }
    //put in returns
    theDataObject = [NSData dataWithBytes:theChars length:(count *2)];
    aRange.length = 80;

    for(i=0;i<groups;i++)
    {
        
        aRange.location = 80 * i;
        [finalString appendString:[[NSString alloc] initWithData:[theDataObject subdataWithRange:aRange] encoding:NSASCIIStringEncoding]];
    }

    if((groups*80)<[theDataObject length])
    {
        aRange.location = 80 * groups;
        aRange.length = [theDataObject length] - aRange.location;
        [finalString appendString:[[NSString alloc] initWithData:[theDataObject subdataWithRange:aRange] encoding:NSASCIIStringEncoding]];
    }
    
    free(theData);
    free(theChars);
    return [NSString stringWithString:finalString];
}

NSData * decodeBase16(NSString * aString)
{
    static char base16[] = {"0123456789ABCDEF"};

    static char base16lc[] = {"0123456789abcdef"};
    unsigned char *theStringContents;
    NSMutableString *workingString = [[NSMutableString alloc] init];
    unsigned char *theData;
    BOOL valid;
    NSCharacterSet *theSet = [NSCharacterSet whitespaceCharacterSet];
    NSScanner *theScanner = [NSScanner scannerWithString:aString];
    NSString *temp;
    NSData *theFinalData;
    int i,j,k;
    
    while(![theScanner isAtEnd])
    {
        [theScanner scanUpToCharactersFromSet:theSet intoString:&temp];
        [workingString appendString:temp];
        [theScanner scanCharactersFromSet:theSet intoString:nil];
    }
    
    //check to make sure we have 2 bytes for each value
    if(([workingString length]/2*2)!=[workingString length])
    {
        //NSLog(@"invalid data");
        return nil;
    }
    valid = YES;
    //if we're here, we have valid data
    theStringContents = (unsigned char *)malloc(sizeof(unsigned char)*[workingString length]);
    theData = (unsigned char *)malloc(sizeof(unsigned char)*[workingString length]/2);
    [[workingString dataUsingEncoding:NSASCIIStringEncoding] getBytes:theStringContents length:sizeof(unsigned char)*[workingString length]/2];
    //now all data are allocated
    for(i=0;i<([workingString length]);i++)
    {
        k = -1;
        for(j=0;j<16;j++)
        {
            if((theStringContents[i]==base16[j])||(theStringContents[i]==base16lc[j]))
            {
                k = 0;
                theStringContents[i] = (unsigned char)j;
                j = 16;
            }
        }
        if(k==-1)
        {
            valid = NO;
            //NSLog(@"invalid character");
        }
    }
    
    if(!valid)
    {
        free(theStringContents);
        free(theData);
        return nil;
    }
    for(i=0;i<[workingString length]/2;i++)
    {
        theData[i] = (theStringContents[(i*2)] << 4) | theStringContents[(i*2)+1];
    }
    theFinalData = [NSData dataWithBytes:theData length:([workingString length]/2)];
    free(theStringContents);
    free(theData);
    return theFinalData;
    
}

NSString * encodeBase64(NSData * data)
{

    char base64[] = {"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"};

    int i,count,groups,j,k;

    NSRange aRange;

    NSMutableString *formatedEncoded = [[NSMutableString alloc] init];

    NSMutableData *mutData = [[NSMutableData alloc] init];
	
    unsigned char *theContents;
	if(!data)
		return nil;

    

    count = (int)[data length];

    groups = (int)(count/3);

    if((groups*3)!=count)
        groups+=1;

    theContents = (unsigned char *)malloc(sizeof(unsigned char)*groups*3);
    for(i=((groups*3)-4);i<(groups*3);i++)
        theContents[i] = 0;
    
    [data getBytes:theContents length:sizeof(unsigned char)*groups*3];
    for(i=0;i<(groups);i++)
    {
        unsigned char bytes[4];
        j = i * 3;
        
        //now we need to convert them in to 4 "6" bit values
        bytes[0] = (theContents[j] >> 2) & 0x3F;/*shifts the bits of theContents[i] 2 to the right, and uses the and operator to clear the first two bits.*/
        bytes[1] = ((theContents[j] << 4) | (theContents[j+1] >> 4)) & 0x3F;/*shifts the bits of theContents[i] 4 to the left, and combines with an or statement theContents[i+1] shifted 4 to the right, and uses the and operator to clear the first two bits.*/
        bytes[2]  = ((theContents[j+1] << 2) | (theContents[j+2] >> 6))& 0x3F;/*shifts the bits of theContents[j+1] 2 to the left, and combines with an or statement theContents[j+2] shifted 6 to the right, and uses the and operator to clear the first two bits.*/
        bytes[3]  = theContents[j+2] & 0x3F;/*no shifting required for the last 6 bits, and uses the and operator to clear the first two bits.*/
        for(k=0;k<4;k++)
        {
            bytes[k] = base64[bytes[k]];
        }
        //now encode null values
        if(j+1>=count)
            bytes[2] = '=';
        if(j+2>=count)
            bytes[3] = '=';
        [mutData appendBytes:bytes length:4];
    }
    //setting encoding to 60 characters wide
    groups = (int)[mutData length]/60;
    aRange.length = 60;
    for(i=0;i<groups;i++)
    {
        aRange.location = i*60;
        [formatedEncoded appendFormat:@"%@\n",[[NSString alloc] initWithData:[mutData subdataWithRange:aRange] encoding:NSASCIIStringEncoding]];
    }
    if(groups*60<[mutData length])
    {
        aRange.location = groups*60;
        aRange.length = [mutData length] - aRange.location;
        [formatedEncoded appendFormat:@"%@",[[NSString alloc] initWithData:[mutData subdataWithRange:aRange] encoding:NSASCIIStringEncoding]];
    }
    free(theContents);
    return [NSString stringWithString:formatedEncoded];

}

NSData * decodeBase64(NSString * aString)
{
    static char base64[] = {"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"};
	static char base64a[] = {"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="};
    unsigned char *allBytes;
    NSMutableData *workingData = [[NSMutableData alloc] init];
    NSMutableData *encodedData  = [[NSMutableData alloc] init];
    //NSCharacterSet *theSet = [NSCharacterSet whitespaceCharacterSet];
	NSCharacterSet *theSet1 = [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithUTF8String:base64a]];
    NSScanner *theScanner = [NSScanner scannerWithString:aString];
    NSString *temp;
    NSData *finalData;
    int i,j,count,padding;
    
    
    padding = 0;
    while(![theScanner isAtEnd])
    {
        [theScanner scanUpToCharactersFromSet:theSet1 intoString:nil];
        [theScanner scanCharactersFromSet:theSet1 intoString:&temp];
        [encodedData appendData:[temp dataUsingEncoding:NSASCIIStringEncoding]];
    }

    count = (int)[encodedData length];
    allBytes =  (unsigned char *)malloc([encodedData length]);
    [encodedData getBytes:allBytes length:count];
    
    for(i=0;i<count;i++)
    {
        if(allBytes[i]=='=')
        {
            allBytes[i] = 0;
            padding++;
        }
        
        for(j=0;j<64;j++)
        {
            if(allBytes[i] == base64[j])
            {
                allBytes[i] = j;
                j=64;
            }
        }
    }
    //all values are converted back to numbers, now to merge the bytes.
    for(i=0;i<(count/4);i++)
    {
        unsigned char val[3];
        int addLength;
        val[0] = (allBytes[i*4] << 2) | (allBytes[i*4+1] >> 4);//no mask
        val[1] = (allBytes[i*4+1] << 4) | (allBytes[i*4+2] >> 2);//no mask
        val[2] = (allBytes[i*4+2] << 6) | (allBytes[i*4+3]);//no mask
        //NSLog(@"%i %i %i %i\n",allBytes[i*4],allBytes[i*4+1],allBytes[i*4+2],allBytes[i*4+3]);
        //NSLog(@"%c %c %c\n",val[0],val[1],val[2]);
        addLength = 3;
        if(i+1==(count/4))
        {
            if(padding>1)
                addLength = 1;
            else if(padding>0)
                addLength = 2;
        }
        [workingData appendBytes:val length:addLength];
                    
    }
    //NSLog(@"new length %i",[workingData length]);
    finalData = [NSData dataWithData:workingData];
    free(allBytes);
    return finalData;
    //return nil;
    
}

NSData * decodeBase64WithEncoding(NSString * aString, unsigned int encoding)
{
    static char base64[] = {"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"};
	static char base64a[] = {"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="};
    unsigned char *allBytes;
    NSMutableData *workingData = [[NSMutableData alloc] init];
    NSMutableData *encodedData  = [[NSMutableData alloc] init];
    //NSCharacterSet *theSet = [NSCharacterSet whitespaceCharacterSet];
	NSCharacterSet *theSet1 = [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithUTF8String:base64a]];
    NSScanner *theScanner = [NSScanner scannerWithString:aString];
    NSString *temp;
    NSData *finalData;
    int i,j,count,padding;

    
    padding = 0;

	while(![theScanner isAtEnd])
    {
        [theScanner scanUpToCharactersFromSet:theSet1 intoString:nil];
        [theScanner scanCharactersFromSet:theSet1 intoString:&temp];
        [encodedData appendData:[temp dataUsingEncoding:encoding]];
    }
	NSLog(@"prior");
	NSLog(@"%@",[[NSString alloc] initWithData:encodedData encoding:encoding]);
    count = (int)[encodedData length];
    allBytes =  (unsigned char *)malloc([encodedData length]);
    [encodedData getBytes:allBytes length:[encodedData length]];
    
    for(i=0;i<count;i++)
    {
        if(allBytes[i]=='=')
        {
            allBytes[i] = 0;
            padding++;
        }
        
        for(j=0;j<64;j++)
        {
            if(allBytes[i] == base64[j])
            {
                allBytes[i] = j;
                j=64;
            }
        }
    }
    //all values are converted back to numbers, now to merge the bytes.
    for(i=0;i<(count/4);i++)
    {
        unsigned char val[3];
        int addLength;
        val[0] = (allBytes[i*4] << 2) | (allBytes[i*4+1] >> 4);//no mask
			val[1] = (allBytes[i*4+1] << 4) | (allBytes[i*4+2] >> 2);//no mask
				val[2] = (allBytes[i*4+2] << 6) | (allBytes[i*4+3]);//no mask
																	//NSLog(@"%i %i %i %i\n",allBytes[i*4],allBytes[i*4+1],allBytes[i*4+2],allBytes[i*4+3]);
																	//NSLog(@"%c %c %c\n",val[0],val[1],val[2]);
					addLength = 3;
					if(i+1==(count/4))
					{
						if(padding>1)
							addLength = 1;
						else if(padding>0)
							addLength = 2;
					}
					[workingData appendBytes:val length:addLength];
                    
    }
    //NSLog(@"new length %i",[workingData length]);
    finalData = [NSData dataWithData:workingData];
    free(allBytes);
    return finalData;
    //return nil;
    
}


//NSString * vectorEncodeBase16(NSData * data)
//{
//    static char base16lc[] = {"0123456789abcdef"};
//    
//    NSData *theDataObject;
//    NSMutableString *finalString = [[NSMutableString alloc] init];
//    int i;
//    int count = [data length];
//    int shortCount;
//    int groups = count * 2 / 80;
//    NSRange aRange;
//    unsigned char *theChars = (unsigned char *)malloc(sizeof(char) * count * 2);
//    unsigned char *theData = (unsigned char *)malloc(sizeof(unsigned char) * count);
//    vector unsigned char vect1, highBits,lowBits,firstBytes,lastBytes;
//    vector unsigned char vecFour = (vector unsigned char)(4);
//    vector unsigned char firstPerm = (vector unsigned char)(0x00,0x10,0x02,0x12,0x04,0x14,0x06,0x16,0x08,0x18,0x0A,0x1A,0x0C,0x1C,0x0E,0x1E);
//    vector unsigned char secondPerm = (vector unsigned char)(0x01,0x11,0x03,0x13,0x05,0x15,0x07,0x17,0x09,0x19,0x0B,0x1B,0x0D,0x1D,0x0F,0x1F);
//    //NSLog(@"data length %i",[data length]);
//    [data getBytes:theData];
//    
//    for(i=0;i<(count/16);i++)//doesn't do the last group if 3 units or less
//    {
//        vect1 = vec_ld(i*16,theData);
//        highBits = vec_sr(vect1,vecFour);
//        lowBits = vec_sl(vect1,vecFour); //clear upper bits by shifting
//        lowBits = vec_sr(lowBits,vecFour);//return bits to proper place
//        //at this point, we have double the bytes so we have to permute twice
//        firstBytes = vec_perm(highBits,lowBits,firstPerm);
//        lastBytes = vec_perm(highBits,lowBits,secondPerm);
//        vec_st(firstBytes,i*32,theChars);
//        vec_st(lastBytes,(i*32)+16,theChars);
//    }
//    if(((count/16)*16)!=count)
//    {
//       shortCount = count - ((count/16)*16);
//        unsigned char shortData[16];
//        unsigned char finalData[32];
//        for(i=0;i<shortCount;i++)
//            shortData[i] = theData[count-shortCount+1];
//        vect1 = vec_ld(i*16,shortData);
//        highBits = vec_sr(vect1,vecFour);
//        lowBits = vec_sl(vect1,vecFour); //clear upper bits by shifting
//        lowBits = vec_sr(lowBits,vecFour);//return bits to proper place
//                                          //at this point, we have double the bytes so we have to permute twice
//            firstBytes = vec_perm(highBits,lowBits,firstPerm);
//            lastBytes = vec_perm(highBits,lowBits,secondPerm);
//            vec_st(firstBytes,0,finalData);
//            vec_st(lastBytes,16,finalData);
//            for(i=0;i<shortCount;i++)
//                theData[count-shortCount+1] = finalData[i];
//    }
//    
//    for(i=0;i<(count*2);i++)
//    {
//        theChars[i] = base16lc[theChars[i]];
//    }
//    //put in returns
//    theDataObject = [NSData dataWithBytes:theChars length:(count *2)];
//    aRange.length = 80;
//    //NSLog(@"try c string");
//    //NSLog([[[NSString alloc] initWithCString:theChars] autorelease]);
//    for(i=0;i<groups;i++)
//    {
//        
//        aRange.location = 80 * i;
//        [finalString appendString:[[NSString alloc] initWithData:[theDataObject subdataWithRange:aRange] encoding:NSASCIIStringEncoding]];
//    }
//    
//    if((groups*80)<[theDataObject length])
//    {
//        aRange.location = 80 * groups;
//        aRange.length = [theDataObject length] - aRange.location;
//        [finalString appendString:[[NSString alloc] initWithData:[theDataObject subdataWithRange:aRange] encoding:NSASCIIStringEncoding]];
//    }
//    
//    free(theData);
//    free(theChars);
//    return [NSString stringWithString:finalString];
//}


//
//  NSString+Slice.m
//  XFTest
//
//  Created by jrk on 24/8/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "NSString+Slice.h"


@implementation NSString (Slice)

- (NSString *) stringBySlicingFrom: (NSUInteger) fromIndex to: (NSInteger) toIndex
{
	//-1 = to the end
	if (toIndex == -1)
		toIndex = [self length];

	//-2 == the 2nd char from the end, etc.
	if (toIndex < -1)
		toIndex = [self length] + toIndex;
	
	//fix for case if toIndex == self lenght 
	if (toIndex < [self length])
		toIndex ++;
	
	//bounds checking
	if (toIndex > [self length] || fromIndex > [self length])
		return nil;
	if (toIndex < fromIndex)
		return nil;
	if (fromIndex < 0)
		return nil;


	NSRange r;
	r.location = fromIndex;
	r.length = (toIndex - fromIndex);
		
	return [self substringWithRange: r];			 
}

- (NSString *) stringBySlicingFrom: (NSUInteger) fromIndex
{
	return [self stringBySlicingFrom: fromIndex to: [self length]];
}
- (NSString *) stringBySlicingTo: (NSInteger) toIndex
{
	return [self stringBySlicingFrom: 0 to: toIndex];
}


- (BOOL)containsString:(NSString *)aString 
{
    return [self containsString:aString ignoringCase:NO];
}

- (BOOL)containsString:(NSString *)aString ignoringCase:(BOOL)flag 
{
    unsigned mask = (flag ? NSCaseInsensitiveSearch : 0);
    return [self rangeOfString:aString options:mask].length > 0;
}

@end

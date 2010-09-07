//
//  NSString+Slice.h
//
//  Created by jrk on 24/8/10.
//  Copyright 2010 flux forge. All rights reserved.
//
//  ruby-like string slicing for nsstring ... because we're all a little retarded :[
//

#import <Foundation/Foundation.h>


@interface NSString (Slice)

//stringBySlicingFrom: to: 
	//returns a substring containing chars from "fromIndex" to "toIndex" (including char at toIndex).
	//to: -1 = to the last char of the string (including last char)
	//to: -2 = to the 2nd last char of the string (including it)
	//to: -3.... " " " "

//stringBySlicingFrom:
	//returns a substring containing chars from fromIndex to the end of the string

//stringBySlicingTo
	//returns a substring containing chars from the beginning of the string to toIndex (including char at toIndex)

- (NSString *) stringBySlicingFrom: (NSUInteger) fromIndex to: (NSInteger) toIndex;
- (NSString *) stringBySlicingFrom: (NSUInteger) fromIndex;
- (NSString *) stringBySlicingTo: (NSInteger) toIndex;


- (BOOL) containsString:(NSString *)aString ignoringCase:(BOOL)flag;
- (BOOL) containsString:(NSString *)aString;

@end

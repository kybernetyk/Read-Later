//
//  MainWindow.m
//  Read Later
//
//  Created by jrk on 30/8/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "MainWindow.h"


@implementation MainWindow
- (void) dealloc
{
	NSLog(@"teh funny goes bad");
	[super dealloc];
}
- (void)close
{
	NSLog(@"app hide!");
	[super close];
	[NSApp hide: self];
}


- (BOOL)canBecomeMainWindow
{
	//	NSLog(@"can become main?");
	
	return YES;
}

- (BOOL)canBecomeKeyWindow
{
	//	NSLog(@"can become key?");
	
	
	return YES;
}

@end

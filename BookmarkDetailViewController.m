//
//  BookmarkDetailViewController.m
//  Read Later
//
//  Created by jrk on 20/9/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "BookmarkDetailViewController.h"
#import "FXBookmark.h"
#import "FXDataCore.h"

@implementation BookmarkDetailViewController
@synthesize titleLabel;
@synthesize urlLabel;
@synthesize addedOnLabel;
@synthesize visitedLabel;

- (void) awakeFromNib
{
	
}

- (void) dealloc
{
	
	NSLog(@"detail view controller dealloc");
	[super dealloc];
}

#pragma mark -
#pragma mark actions
- (void) handleRemoveBookmarkButton: (id) sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName: @"FXRemoveBookmarkButtonPressed" object: [self representedObject]];
}

- (void) handleVisitButton: (id) sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName: @"FXVisitBookmarkButtonPressed" object: [self representedObject]];
}

- (IBAction) readCheckboxValueChanged: (id) sender
{
	[[FXDataCore sharedCore] saveContextWithDelayedSync];
}

@end

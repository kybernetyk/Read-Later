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
	[[[FXDataCore sharedCore] managedObjectContext] deleteObject: [self representedObject]];
	[[FXDataCore sharedCore] saveContextWithDelayedSync];	
}

- (void) handleVisitButton: (id) sender
{
	FXBookmark *bookmark = (FXBookmark *)[self representedObject];
	[bookmark setLastVisited: [NSNumber numberWithBool: YES]];
	
	NSLog(@"visiting: %@", [bookmark URL]);
	[bookmark setVisited: [NSNumber numberWithBool: YES]];
	[[FXDataCore sharedCore] saveContextWithDelayedSync];
	
	NSURL *url = [NSURL URLWithString: [bookmark URL]];
	[[NSWorkspace sharedWorkspace] openURL: url];
	
}

- (IBAction) readCheckboxValueChanged: (id) sender
{
	[[FXDataCore sharedCore] saveContextWithDelayedSync];
}

@end

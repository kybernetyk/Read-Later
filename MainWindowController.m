//
//  MainWindowController.m
//  Read Later
//
//  Created by jrk on 30/8/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "MainWindowController.h"
#import "FXDataCore.h"
#import "FXBookmark.h"

@implementation MainWindowController
@synthesize sidebarView;
@synthesize bookmarksView;

- (void) updateFrameAutosave
{
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	NSString *frameName = [defs stringForKey: kDefsKeysMainWindowAutosaveFrameName];
	if (!frameName)
		frameName = @"";
	[[self window] setFrameAutosaveName: frameName];
	
}

- (void) windowDidLoad
{
	[super windowDidLoad];
	NSLog(@"window will load ...");
	
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver: self selector:@selector(makeViewFirstResponder:) name: @"FXMakeViewFirstResponder" object: nil];

	
	[self updateFrameAutosave];
	[self createSidebarView];
	[self createBookmarksView];

	
//	[[self window] makeFirstResponder: [listViewController tableView]];
	
	
/*	if ([tableView selectedRow] >= 0)
	{
		FXBookmark *bookmark = [[self bookmarks] objectAtIndex: [tableView selectedRow]];
		[self createDetailViewWithBookmark: bookmark];
	}
	
	NSLog(@"window did load");
	[self markNextBookmark];*/
	

}

- (void) makeViewFirstResponder: (NSNotification *) notification
{
	NSView *view = [notification object];
	if (!view)
		return;
	
	[[self window] makeFirstResponder: view];
}

- (void) dealloc
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center removeObserver: self];
	
	[self destroySidebarView];
	[self destroyBookmarksView];
	
	[self setBookmarksView: nil];
	[self setSidebarView: nil];
	
	NSLog(@"MainWindowController dealloc!");
//	NSLog(@"dealloc du fotze: %i", [tableView retainCount]);
	
	

	[super dealloc];
}



#pragma mark -
#pragma mark sidebar view
- (void) createSidebarView
{
	sidebarViewController = [[SidebarViewController alloc] initWithNibName: @"SidebarView" bundle: nil];

	NSRect frame = [[sidebarViewController view] frame];
	frame.size.width = [sidebarView frame].size.width;
	frame.size.height = [sidebarView frame].size.height;
	
	[[sidebarViewController view] setFrame: frame];
	[sidebarView addSubview: [sidebarViewController view]];
}

- (void) destroySidebarView
{
	[[sidebarViewController view] removeFromSuperview];
	[sidebarViewController release];
	sidebarViewController = nil;
}

#pragma mark -
#pragma mark bookmarks view
- (void) createBookmarksView
{
	bookmarksViewController = [[BookmarksViewController alloc] initWithNibName: @"BookmarksView" bundle: nil];
	
	NSRect frame = [[bookmarksViewController view] frame];
	frame.size.width = [bookmarksView frame].size.width;
	frame.size.height = [bookmarksView frame].size.height;
	
	[[bookmarksViewController view] setFrame: frame];
	[bookmarksView addSubview: [bookmarksViewController view]];
}

- (void) destroyBookmarksView
{
	[[bookmarksViewController view] removeFromSuperview];
	[bookmarksViewController release];
	bookmarksViewController = nil;
}

@end

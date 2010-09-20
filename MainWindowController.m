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
	[center addObserver: self selector:@selector(changeDetailView:) name: @"FXBookmarkSelectionDidChange" object: nil];

	
	[self updateFrameAutosave];
	[self createSidebarView];
	[self createListView];

	[[self window] makeFirstResponder: [listViewController tableView]];
	
	
/*	if ([tableView selectedRow] >= 0)
	{
		FXBookmark *bookmark = [[self bookmarks] objectAtIndex: [tableView selectedRow]];
		[self createDetailViewWithBookmark: bookmark];
	}
	
	NSLog(@"window did load");
	[self markNextBookmark];*/
	

}

- (void) changeDetailView: (NSNotification *) notification
{
	[self destroyDetailView];
	
	FXBookmark *bm = [notification object];
	[self createDetailViewWithBookmark: bm];
}

- (void) dealloc
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center removeObserver: self];
	
	[self destroySidebarView];
	[self destroyListView];
	[self destroyDetailView];
	
	NSLog(@"MainWindowController dealloc!");
//	NSLog(@"dealloc du fotze: %i", [tableView retainCount]);
	
	

	[super dealloc];
}



#pragma mark -
#pragma mark list view
- (void) createListView
{
	//sidebarViewController = [[SidebarViewController alloc] initWithNibName: @"SidebarView" bundle: nil];
	listViewController = [[BookmarkListViewController alloc] initWithNibName: @"BookmarkListView" bundle: nil];
	
	NSRect frame = [[listViewController view] frame];
	frame.size.width = [listView frame].size.width;
	frame.size.height = [listView frame].size.height;
	
	[[listViewController view] setFrame: frame];
	[listView addSubview: [listViewController view]];
}

- (void) destroyListView
{
	[[listViewController view] removeFromSuperview];
	[listViewController release];
	listViewController = nil;
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
#pragma mark detail view
- (void) destroyDetailView
{
	[[detailViewController view] removeFromSuperview];
	[detailViewController release];
	detailViewController = nil;
}

- (void) createDetailViewWithBookmark: (FXBookmark *) bookmark
{
	if (!bookmark)
		return;
	
	detailViewController = [[BookmarkDetailViewController alloc] initWithNibName: @"DetailView" bundle: nil];
	[detailViewController setRepresentedObject: bookmark];
	
	NSRect frame = [[detailViewController view] frame];
	frame.size.width = [detailView frame].size.width;
	frame.size.height = [detailView frame].size.height;
	
	[[detailViewController view] setFrame: frame];
	[detailView addSubview: [detailViewController view]];
}


@end

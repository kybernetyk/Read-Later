//
//  BookmarksViewController.m
//  Read Later
//
//  Created by jrk on 20/9/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "BookmarksViewController.h"


@implementation BookmarksViewController
@synthesize listView;
@synthesize detailView;

- (void) awakeFromNib
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver: self selector:@selector(changeDetailView:) name: @"FXBookmarkSelectionDidChange" object: nil];

	[self createListView];
	//[self createDetailViewWithBookmark: nil];
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	[self destroyListView];
	[self destroyDetailView];

	[self setListView: nil];
	[self setDetailView: nil];
	[super dealloc];
}


- (void) changeDetailView: (NSNotification *) notification
{
	[self destroyDetailView];
	
	FXBookmark *bm = [notification object];
	[self createDetailViewWithBookmark: bm];
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

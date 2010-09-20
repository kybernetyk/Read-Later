//
//  MainWindowController.h
//  Read Later
//
//  Created by jrk on 30/8/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BookmarkDetailViewController.h"
#import "FXBookmark.h"
#import "SidebarViewController.h"
#import "BookmarkListViewController.h"

@interface MainWindowController : NSWindowController 
{
	IBOutlet NSView *listView;
	IBOutlet NSView *detailView;
	IBOutlet NSView *sidebarView;
	
	BookmarkDetailViewController *detailViewController;
	SidebarViewController *sidebarViewController;
	BookmarkListViewController *listViewController;
	
	//NSArray *bookmarks;
}


//@property (retain) NSArray *bookmarks;
- (void) updateFrameAutosave;


- (void) createListView;
- (void) destroyListView;

- (void) createSidebarView;
- (void) destroySidebarView;

- (void) destroyDetailView;
- (void) createDetailViewWithBookmark: (FXBookmark *) bookmark;


@end

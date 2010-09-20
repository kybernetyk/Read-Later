//
//  MainWindowController.h
//  Read Later
//
//  Created by jrk on 30/8/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BookmarksViewController.h"
#import "SidebarViewController.h"


@interface MainWindowController : NSWindowController 
{
	IBOutlet NSView *sidebarView;
	IBOutlet NSView *bookmarksView;
	
	SidebarViewController *sidebarViewController;
	BookmarksViewController *bookmarksViewController;
	
	//NSArray *bookmarks;
}


//@property (retain) NSArray *bookmarks;
- (void) updateFrameAutosave;

- (void) createSidebarView;
- (void) destroySidebarView;

- (void) createBookmarksView;
- (void) destroyBookmarksView;


@end

//
//  MainWindowController.h
//  Read Later
//
//  Created by jrk on 30/8/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BookmarkDetailViewController.h"
#import "SidebarViewController.h"

@interface MainWindowController : NSWindowController 
{
	IBOutlet NSTableView *tableView;
	
	IBOutlet NSView *detailView;
	IBOutlet NSView *sidebarView;
	
	BookmarkDetailViewController *detailViewController;
	SidebarViewController *sidebarViewController;
	
	NSArray *bookmarks;
}
@property (retain) NSTableView *tableView;
@property (retain) NSArray *bookmarks;
- (void) updateFrameAutosave;
- (NSArray *) bookmarks;

@end

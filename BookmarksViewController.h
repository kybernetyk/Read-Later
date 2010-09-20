//
//  BookmarksViewController.h
//  Read Later
//
//  Created by jrk on 20/9/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BookmarkDetailViewController.h"
#import "FXBookmark.h"
#import "BookmarkListViewController.h"


@interface BookmarksViewController : NSViewController 
{
	IBOutlet NSView *listView;
	IBOutlet NSView *detailView;

	BookmarkListViewController *listViewController;
	BookmarkDetailViewController *detailViewController;

}

@property (retain) NSView *listView;
@property (retain) NSView *detailView;

- (void) createListView;
- (void) destroyListView;

- (void) destroyDetailView;
- (void) createDetailViewWithBookmark: (FXBookmark *) bookmark;


@end

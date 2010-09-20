//
//  BookmarkListViewController.h
//  Read Later
//
//  Created by jrk on 20/9/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FXDataCore.h"
#import "FXBookmark.h"


@interface BookmarkListViewController : NSViewController 
{
	IBOutlet NSTableView *tableView;
}

@property (retain) NSTableView *tableView;

- (NSArray *) bookmarks;

@end

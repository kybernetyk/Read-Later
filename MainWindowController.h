//
//  MainWindowController.h
//  Read Later
//
//  Created by jrk on 30/8/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MainWindowController : NSWindowController 
{
	IBOutlet NSTableView *tableView;
	
	NSArray *bookmarks;
}
@property (retain) NSTableView *tableView;
@property (retain) NSArray *bookmarks;
- (IBAction) visitButton: (id) sender;
- (IBAction) removeBookmarkButton: (id) sender;
- (void) updateFrameAutosave;
- (NSArray *) bookmarks;

@end

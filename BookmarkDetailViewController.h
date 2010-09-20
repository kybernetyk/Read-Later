//
//  BookmarkDetailViewController.h
//  Read Later
//
//  Created by jrk on 20/9/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BookmarkDetailViewController : NSViewController 
{
	IBOutlet NSTextField *titleLabel;
	IBOutlet NSTextField *urlLabel;
	IBOutlet NSTextField *addedOnLabel;
	IBOutlet NSTextField *visitedLabel;
}

@property (readwrite, retain) NSTextField *titleLabel;
@property (readwrite, retain) NSTextField *urlLabel;
@property (readwrite, retain) NSTextField *addedOnLabel;
@property (readwrite, retain) NSTextField *visitedLabel;

- (IBAction) handleVisitButton: (id) sender;
- (IBAction) handleRemoveBookmarkButton: (id) sender;
- (IBAction) readCheckboxValueChanged: (id) sender;

@end

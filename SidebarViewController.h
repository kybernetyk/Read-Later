//
//  SidebarViewController.h
//  Read Later
//
//  Created by jrk on 20/9/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SidebarViewController : NSViewController
{
	IBOutlet NSOutlineView *outlineView;
}
@property (readwrite, retain) NSOutlineView *outlineView;

@end

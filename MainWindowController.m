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
@synthesize tableView;
@synthesize bookmarks;

- (void) markNextBookmark
{
	NSArray *bookmarks = [self bookmarks];
	
	FXBookmark *lastBookmark = nil;
	for (FXBookmark *bookmark in bookmarks)
	{
		if ([[bookmark lastVisited] boolValue])
		{	
			lastBookmark = bookmark;
			break;
		}
	}
	
	NSUInteger i = [bookmarks indexOfObject: lastBookmark];
	if (i == NSNotFound)
	{	
		return;
	}
	else
	{
		i++;		
	}
	
	if (i >= [bookmarks count])
		i--;
	
	[tableView selectRow: i byExtendingSelection: NO];
	
}
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
	
	[self updateFrameAutosave];
	NSLog(@"window did load");
	[self markNextBookmark];	
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver: self selector:@selector(syncSessionDidFinish:) name: @"SyncHelperDidFinishSyncSession" object: nil];
}

- (void) syncSessionDidFinish: (id) whatever
{
	[self setBookmarks: nil];
	
	NSLog(@"sync notification: %@", whatever);
	[tableView reloadData];
	//[self markNextBookmark];
}

- (NSArray *) bookmarks
{
	//if (bookmarks)
	//	return bookmarks;
	
	FXDataCore *dataCore = [FXDataCore sharedCore];
	
	NSManagedObjectContext *moc = [dataCore managedObjectContext];
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Bookmark" inManagedObjectContext:moc];
	
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:entityDescription];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"added" ascending:YES];
	[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	
	
	NSError *error;
	NSArray *array = [moc executeFetchRequest:request error:&error];
	return array;
//	return bookmarks;
	
}



- (IBAction) removeBookmarkButton: (id) sender
{
	NSUInteger i = [tableView selectedRow];
	if (i == NSNotFound || i == -1) 
		return;

	NSArray *bookmarks = [self bookmarks];
	FXBookmark *bookmark = [bookmarks objectAtIndex: i];
	
	[[[FXDataCore sharedCore] managedObjectContext] deleteObject: bookmark];
	
	[[FXDataCore sharedCore] saveContextWithDelayedSync];	
	[self setBookmarks: nil]; //trigger reload of stuff
	
	bookmarks = [self bookmarks];
	
	if (i >= [bookmarks count])
		i = [bookmarks count] - 1;
	if (i < 0)
		i = 0;
	[tableView reloadData];
	[tableView selectRow: i byExtendingSelection: NO];
	
}

- (IBAction) visitButton: (id) sender
{
	NSUInteger i = [tableView selectedRow];
	if (i == NSNotFound)
		return;
	NSArray *bookmarks = [self bookmarks];
	if (i >= [bookmarks count] || i < 0)
		return;

	for (FXBookmark *bookmark in bookmarks)
	{
		[bookmark setLastVisited: [NSNumber numberWithBool: NO]];
	}
	
	FXBookmark *bookmark = [bookmarks objectAtIndex: i];
	[bookmark setLastVisited: [NSNumber numberWithBool: YES]];
	
	
	NSLog(@"visiting: %@", [bookmark URL]);
	[bookmark setVisited: [NSNumber numberWithBool: YES]];
	[[FXDataCore sharedCore] saveContextWithDelayedSync];
	[self setBookmarks: nil]; //trigger reload of stuff
	
	NSURL *url = [NSURL URLWithString: [bookmark URL]];
	[[NSWorkspace sharedWorkspace] openURL: url];

}

- (void) dealloc
{
	NSLog(@"MainWindowController dealloc!");

	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center removeObserver: self];
	
	[tableView setDataSource: nil];
	[tableView setDelegate: nil];
	[tableView release];
	
	NSLog(@"dealloc du fotze: %i", [[self window] retainCount]);
	[super dealloc];
}

#pragma mark -
#pragma mark tableview datasource
// Datasource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [[self bookmarks] count];
}


- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	if (rowIndex >= [[self bookmarks] count] || rowIndex < 0)
		return;

	FXBookmark *bookmark = [[self bookmarks] objectAtIndex: rowIndex];
	
	
	if ([[aTableColumn identifier] isEqualToString: @"visited"])
		return [bookmark valueForKey: [aTableColumn identifier]];	
	
	NSString *title = [NSString stringWithFormat: @"%@", [bookmark siteTitle]];
	
	if (!title || [title length] == 0)
		return [NSString stringWithFormat: @"%@",[bookmark URL]];
	
	return [NSString stringWithFormat: @"%@ (%@)", title, [bookmark URL]];
	
	
}
- (NSString *)tableView:(NSTableView *)aTableView 
		 toolTipForCell:(NSCell *)aCell 
				   rect:(NSRectPointer)rect 
			tableColumn:(NSTableColumn *)aTableColumn 
					row:(NSInteger)row 
		  mouseLocation:(NSPoint)mouseLocation
{
	if ([[aTableColumn identifier] isEqualToString: @"URL"])
	{
		FXBookmark *bm = [[self bookmarks] objectAtIndex: row];
		if ([bm siteTitle])
			return [bm siteTitle];
		
		return [bm URL];
	}
	
	return nil;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	//	[[parentObject session] setCurrentSelectedIndex: [tableView selectedRow]];
//	[[parentObject session] setCurrentlySelectedEntry: [tableView selectedRow]];
//	FXBookmark *bookmark = [[self bookmarks] objectAtIndex: [tableView selectedRow]];
	
//	NSLog(@"bookmark: %@/%@/%@",[bookmark URL],[bookmark siteTitle], [bookmark note]);

}


@end

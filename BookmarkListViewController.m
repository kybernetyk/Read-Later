//
//  BookmarkListViewController.m
//  Read Later
//
//  Created by jrk on 20/9/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "BookmarkListViewController.h"


@implementation BookmarkListViewController
@synthesize tableView;

- (void) awakeFromNib
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver: self selector:@selector(syncSessionDidFinish:) name: @"SyncHelperDidFinishSyncSession" object: nil];
	[center addObserver: self selector:@selector(dataChanged:) name: NSManagedObjectContextDidSaveNotification object: [[FXDataCore sharedCore] managedObjectContext]];
	[center addObserver: self selector:@selector(removeBookmarkButton:) name: @"FXRemoveBookmarkButtonPressed" object: nil];
	[center addObserver: self selector:@selector(visitButton:) name: @"FXVisitBookmarkButtonPressed" object: nil];	
	
	[tableView selectRow: 0 byExtendingSelection: NO];
	[tableView setAllowsEmptySelection: NO];
	
	[self markNextBookmark];
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"FXBookmarkSelectionDidChange" object: bookmark];
}

- (void) dealloc
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center removeObserver: self];

	
	//IMPORTANT: if the app crashes in NSTableView drawRect or something
	//you have forgotten to connect the table view in IB to this class' outlet!
	//connect the table view to the tableView outlet!
	
	
	//important so the table view does not poll our dead body
	//the table view will be released shortly after us
	[tableView setDataSource: nil];
	[tableView setDelegate: nil];
	[self setTableView: nil];
	
	
	[super dealloc];
}


- (void) markNextBookmark
{
	NSArray *_bookmarks = [self bookmarks];
	
	FXBookmark *lastBookmark = nil;
	for (FXBookmark *bookmark in _bookmarks)
	{
		if ([[bookmark lastVisited] boolValue])
		{	
			lastBookmark = bookmark;
			break;
		}
	}
	
	NSUInteger i = [_bookmarks indexOfObject: lastBookmark];
	if (i == NSNotFound)
	{	
		return;
	}
	else
	{
		i++;		
	}
	
	if (i >= [_bookmarks count])
		i--;
	
	[tableView selectRow: i byExtendingSelection: NO];
	
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

- (void) dataChanged: (id) notification
{
	
	NSLog(@"data changed baby!");
	[tableView reloadData];
	
	FXBookmark *bookmark = nil;
	if ([tableView selectedRow] >= 0)
		bookmark = [[self bookmarks] objectAtIndex: [tableView selectedRow]];

	[[NSNotificationCenter defaultCenter] postNotificationName:@"FXBookmarkSelectionDidChange" object: bookmark];
}

- (void) syncSessionDidFinish: (id) whatever
{
	NSLog(@"sync notification: %@", whatever);
	[tableView reloadData];
	//[self markNextBookmark];
}




- (IBAction) removeBookmarkButton: (id) sender
{
	NSUInteger i = [tableView selectedRow];
	if (i == NSNotFound || i == -1) 
		return;
	
	NSArray *_bookmarks = [self bookmarks];
	FXBookmark *bookmark = [_bookmarks objectAtIndex: i];
	[[[FXDataCore sharedCore] managedObjectContext] deleteObject: bookmark];
	[[FXDataCore sharedCore] saveContextWithDelayedSync];	
	
	_bookmarks = [self bookmarks];
	
	if (i >= [_bookmarks count])
		i = [_bookmarks count] - 1;
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
	NSArray *_bookmarks = [self bookmarks];
	if (i >= [_bookmarks count] || i < 0)
		return;
	
	for (FXBookmark *bookmark in _bookmarks)
	{
		[bookmark setLastVisited: [NSNumber numberWithBool: NO]];
	}
	
	FXBookmark *bookmark = [_bookmarks objectAtIndex: i];
	[bookmark setLastVisited: [NSNumber numberWithBool: YES]];
	
	
	NSLog(@"visiting: %@", [bookmark URL]);
	[bookmark setVisited: [NSNumber numberWithBool: YES]];
	[[FXDataCore sharedCore] saveContextWithDelayedSync];
	
	NSURL *url = [NSURL URLWithString: [bookmark URL]];
	[[NSWorkspace sharedWorkspace] openURL: url];
	
}

#pragma mark -
#pragma mark tableview datasource
// Datasource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	//	NSLog(@"num: %i", [[self bookmarks] count]);
	return [[self bookmarks] count];
}


- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	if ([[self bookmarks] count] == 0)
		return nil;
	
	if (rowIndex >= [[self bookmarks] count] || rowIndex < 0)
		return nil;
	
	FXBookmark *bookmark = [[self bookmarks] objectAtIndex: rowIndex];
	//NSLog(@"bookmark: %@", bookmark);
	
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

#pragma mark -
#pragma mark tableview delegate
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	NSLog(@"bum bum penis!");
	FXBookmark *bookmark = nil;
	if ([tableView selectedRow] >= 0)
		bookmark = [[self bookmarks] objectAtIndex: [tableView selectedRow]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FXBookmarkSelectionDidChange" object: bookmark];
}


@end

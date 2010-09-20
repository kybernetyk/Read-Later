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
	NSLog(@"window will load ...");
	
	[self updateFrameAutosave];
	[self createSidebarView];
	
	if ([tableView selectedRow] >= 0)
	{
		FXBookmark *bookmark = [[self bookmarks] objectAtIndex: [tableView selectedRow]];
		[self createDetailViewWithBookmark: bookmark];
	}
	
	NSLog(@"window did load");
	[self markNextBookmark];
	
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver: self selector:@selector(syncSessionDidFinish:) name: @"SyncHelperDidFinishSyncSession" object: nil];
	[center addObserver: self selector:@selector(dataChanged:) name: NSManagedObjectContextDidSaveNotification object: [[FXDataCore sharedCore] managedObjectContext]];
	[center addObserver: self selector:@selector(removeBookmarkButton:) name: @"FXRemoveBookmarkButtonPressed" object: nil];
	[center addObserver: self selector:@selector(visitButton:) name: @"FXVisitBookmarkButtonPressed" object: nil];	
	
}

- (void) dataChanged: (id) notification
{
	
	NSLog(@"data changed baby!");
	[tableView reloadData];
	
	[self destroyDetailView];
	if ([tableView selectedRow] < 0)
		return;
	FXBookmark *bookmark = [[self bookmarks] objectAtIndex: [tableView selectedRow]];
	[self createDetailViewWithBookmark: bookmark];
	
}

- (void) syncSessionDidFinish: (id) whatever
{
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

- (void) dealloc
{
	//IMPORTANT: if the app crashes in NSTableView drawRect or something
	//you have forgotten to connect the table view in IB to this class' outlet!
	//connect the table view to the tableView outlet!
	
	[self destroySidebarView];
	[self destroyDetailView];
	
	NSLog(@"MainWindowController dealloc!");
//	NSLog(@"dealloc du fotze: %i", [tableView retainCount]);
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center removeObserver: self];
	
	//important so the table view does not poll our dead body
	//the table view will be released shortly after us
	[tableView setDataSource: nil];
	[tableView setDelegate: nil];
	[self setTableView: nil];
	

	[super dealloc];
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
	[self destroyDetailView];
	if ([tableView selectedRow] < 0)
		return;
	FXBookmark *bookmark = [[self bookmarks] objectAtIndex: [tableView selectedRow]];
	[self createDetailViewWithBookmark: bookmark];
}




#pragma mark -
#pragma mark sidebar view
- (void) createSidebarView
{
	sidebarViewController = [[SidebarViewController alloc] initWithNibName: @"SidebarView" bundle: nil];

	NSRect frame = [[sidebarViewController view] frame];
	frame.size.width = [sidebarView frame].size.width;
	frame.size.height = [sidebarView frame].size.height;
	
	[[sidebarViewController view] setFrame: frame];
	[sidebarView addSubview: [sidebarViewController view]];
}

- (void) destroySidebarView
{
	[[sidebarViewController view] removeFromSuperview];
	[sidebarViewController release];
	sidebarViewController = nil;
}

#pragma mark -
#pragma mark detail view
- (void) destroyDetailView
{
	[[detailViewController view] removeFromSuperview];
	[detailViewController release];
	detailViewController = nil;
}

- (void) createDetailViewWithBookmark: (FXBookmark *) bookmark
{
	if (!bookmark)
		return;
	
	detailViewController = [[BookmarkDetailViewController alloc] initWithNibName: @"DetailView" bundle: nil];
	[detailViewController setRepresentedObject: bookmark];
	
	NSRect frame = [[detailViewController view] frame];
	frame.size.width = [detailView frame].size.width;
	frame.size.height = [detailView frame].size.height;
	
	[[detailViewController view] setFrame: frame];
	[detailView addSubview: [detailViewController view]];
}


@end

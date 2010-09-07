//
//  Read_Later_AppDelegate.m
//  Read Later
//
//  Created by jrk on 30/8/10.
//  Copyright flux forge 2010 . All rights reserved.
//

#import "Read_Later_AppDelegate.h"
#import "FXDataCore.h"
#import "FXBookmark.h"
#import "FXSyncHelper.h"
#import "CFobLicVerifier.h"
#import "FXFetchSiteTitleOperation.h"
#import "NSString+URLEncoding.h"

@implementation Read_Later_AppDelegate
@synthesize shouldShowWindow;

- (BOOL) isRegistered
{
	NSString *key = @"MIHxMIGpBgcqhkjOOAQBMIGdAkEA4fSnVRiCLGWKxIkuwOCeQjM4nX2gRoUQJHjX\n"
	"xHT2TBlDEJG2+eJEGr5l6m2LCQ1NYN3p979f5opOJjJnoqz4tQIVAN22Ks1yW+/r\n"
	"KwJge0BSkvbUEQwtAkEA0v29Q/dLIgHyKQYSm9ab1tmHCGHzQIebAKvjIGwJ/iDY\n"
	"bLTOtxAwznknXSCdDhz/vKb037EVNmOps/2ZJRVwFQNDAAJAWTt9Du4NC7WeSNc1\n"
	"p249qWrHcJsMMZyp7K9+em71ptGYGyXoMcvwj95TxgV5VWlTKGvafXXW6ByOW3k2\n"
	"BfDpyQ==\n";
	
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	
	NSString *name = [defs stringForKey: @"owner"];
	NSString *license = [defs stringForKey: @"license"];
	
	NSLog(@"checking register for %@ / %@", name, license);
	
	NSString *pubKey = [CFobLicVerifier completePublicKeyPEM: key];
	CFobLicVerifier *verifier = [CFobLicVerifier verifierWithPublicKey:pubKey];
	[verifier setRegName: name];
	[verifier setRegCode: license];
	return [verifier verify];
}

- (void)handleURLEvent:(NSAppleEventDescriptor*)event withReplyEvent:(NSAppleEventDescriptor*)replyEvent
{
	[self setShouldShowWindow: YES];
	[self showMainWindow];

	
	if ([self isRegistered])
	{
		NSAlert *al = [NSAlert alertWithMessageText:@"Already Registered" defaultButton:@"Ok" alternateButton: nil otherButton: nil informativeTextWithFormat:@"This copy of Read Later is already registered. :-)"];
		[al setAlertStyle: NSWarningAlertStyle];
		[al runModal];
		
		//[self hideMainWindow];
		return;
	}
	
    NSString* url = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];

	NSArray *protocolAndTheRest = [url componentsSeparatedByString:@"://"];
	if ([protocolAndTheRest count] != 2) 
	{
		NSAlert *al = [NSAlert alertWithMessageText:@"License URL Invalid" defaultButton:@"Ok" alternateButton: nil otherButton: nil informativeTextWithFormat:@"The license link you clicked on was invalid. Try again or enter the license information manually in the preferences dialog."];
		[al setAlertStyle: NSWarningAlertStyle];
		[al runModal];
//		[self hideMainWindow];
		return;
	}
	
	// Separate user name and serial number
	NSArray *userNameAndSerialNumber = [[protocolAndTheRest objectAtIndex:1] componentsSeparatedByString:@"/"];
	if ([userNameAndSerialNumber count] != 2) 
	{
		NSAlert *al = [NSAlert alertWithMessageText:@"Already Registered" defaultButton:@"Ok" alternateButton: nil otherButton: nil informativeTextWithFormat:@"The license link you clicked on was invalid. Try again or enter the license information manually in the preferences dialog."];
		[al setAlertStyle: NSWarningAlertStyle];
		[al runModal];
		
//		[self hideMainWindow];
		return;
	}
	
	// Decode base64-encoded user name
	NSString *usernameEncoded = (NSString *)[userNameAndSerialNumber objectAtIndex:0];
	NSString *username = [usernameEncoded URLDecodedString];
	NSLog(@"User name: %@", username);
	NSString *serial = (NSString *)[userNameAndSerialNumber objectAtIndex:1];
	NSLog(@"Serial: %@", serial);
	
	if (!username || !serial)
	{	
		NSAlert *al = [NSAlert alertWithMessageText:@"Already Registered" defaultButton:@"Ok" alternateButton: nil otherButton: nil informativeTextWithFormat:@"The license link you clicked on was invalid. Try again or enter the license information manually in the preferences dialog."];
		[al setAlertStyle: NSWarningAlertStyle];
		[al runModal];
		
//		[self hideMainWindow];
		return;
	}
	

	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	[defs setObject: username forKey: @"owner"];
	[defs setObject: serial forKey: @"license"];
	[defs synchronize];
	
	if ([self isRegistered])
	{
		NSAlert *al = [NSAlert alertWithMessageText:@"Registration Successful" defaultButton:@"Ok" alternateButton: nil otherButton: nil informativeTextWithFormat:@"The registration was successful. Thank you for registering Read Later!\n\nRead Later will restart now."];
		[al setAlertStyle: NSInformationalAlertStyle];
		[al runModal];
		
		// Relaunch.
		// The shell script waits until the original app process terminates.
		// This is done so that the relaunched app opens as the front-most app.
		
		NSBundle *mainBundle = [NSBundle mainBundle];
		NSString *bundlePath = [mainBundle bundlePath];
		
		int pid = [[NSProcessInfo processInfo] processIdentifier];
		NSString *script = [NSString stringWithFormat:@"while [ `ps -p %d | wc -l` -gt 1 ]; do sleep 0.1; done; open '%@'", pid, bundlePath];
		[NSTask launchedTaskWithLaunchPath:@"/bin/sh" arguments:[NSArray arrayWithObjects:@"-c", script, nil]];
		[NSApp terminate:nil];
		
	}
	else 
	{
		NSAlert *al = [NSAlert alertWithMessageText:@"Registration Failed" defaultButton:@"Ok" alternateButton: nil otherButton: nil informativeTextWithFormat:@"The registration failed. Check if you entered everything correctly and try again.\n\nShould the registration fail again contact the support: supportfluxforge.com"];
		[al setAlertStyle: NSWarningAlertStyle];
		[al runModal];
		
	}
	
	
}

#pragma mark -
#pragma mark app delegate 
-(void)applicationDidFinishLaunching:(NSNotification *)aNotification 
{

	titleQueue = [[NSOperationQueue alloc] init];
	NSLog(@"applicationDidFinishLaunching");
	[NSApp setServicesProvider:self];
	
	//Register the Hotkeys
	EventHotKeyRef gMyHotKeyRef;
	EventHotKeyID gMyHotKeyID;
	EventTypeSpec eventType;
	eventType.eventClass=kEventClassKeyboard;
	eventType.eventKind=kEventHotKeyPressed;
	
	//register hotkey handler
	InstallApplicationEventHandler(&MyHotKeyHandler,1,&eventType,self,NULL);
	
	//register hotkey (option + tab)
	gMyHotKeyID.signature='htk1';
	gMyHotKeyID.id=1;
	//RegisterEventHotKey(49, cmdKey+optionKey, gMyHotKeyID, 	GetApplicationEventTarget(), 0, &gMyHotKeyRef);
	RegisterEventHotKey(48, optionKey, gMyHotKeyID, GetApplicationEventTarget(), 0, &gMyHotKeyRef);
	
	//	UnregisterEventHotKey(gMyHotKeyRef);
	[[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
	
	[self setShouldShowWindow: YES];
	[self registerUserDefaults];
	
	if (![self isRegistered])
	{
		NSLog(@"lol! we're not regist0rd!");
	}
	
	//fire up our core data stuff
	NSError *err;
	[[[FXDataCore sharedCore] syncHelper] performSync: &err];
	
	
	[self registerObservers];
	[self showMainWindow];
}

- (void) registerUserDefaults
{
	NSDictionary *regDict = [NSDictionary dictionaryWithObjectsAndKeys:
							 @"mainWindowFrameAutosave",kDefsKeysMainWindowAutosaveFrameName,
							//@"Jaroslaw Szpilewski", @"owner",
							// @"GAXAE-F9A3A-LH9KU-6XECT-FR34S-J9PHA-YT6ZA-XR7VA-A9KQB-SUSN5-RGXSJ-SYU29-TVJXF-79TYD-GBH3V-UC", @"license",
							 nil];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults: regDict];
}

- (void) resetSavedWindowFrame
{
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	NSString *frameName = [defs stringForKey: kDefsKeysMainWindowAutosaveFrameName];
	//if (!frameName || [frameName length] <= 0)
	//	return;
	[NSWindow removeFrameUsingName: frameName];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	[[FXDataCore sharedCore] saveContext];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
	NSLog(@"reopen");
	[self setShouldShowWindow: YES];
	[self showMainWindow];
	return YES;
}

- (void)applicationDidBecomeActive:(NSNotification *)aNotification
{
	NSLog(@"applicationDidBecomeActive");
	[self showMainWindow];
}

- (void)applicationWillResignActive:(NSNotification *)aNotification
{
	shouldShowWindow = NO;
	[self hideMainWindow];
}

#pragma mark -
#pragma mark actions
- (IBAction) openPreferencesWindow: (id) sender
{
	[[PreferencesWindowController sharedPrefsWindowController] showWindow: nil];
}

#pragma mark -
#pragma mark defaults observer
- (void) registerObservers
{
	NSUserDefaultsController *defc = [NSUserDefaultsController sharedUserDefaultsController];
	[defc addObserver: self 
		   forKeyPath: [NSString stringWithFormat: @"values.%@",kDefsKeysShouldRememberWindowPosition] 
			  options: NSKeyValueObservingOptionNew 
			  context: @"defaults"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
	if ([keyPath isEqualToString: [NSString stringWithFormat: @"values.%@",kDefsKeysShouldRememberWindowPosition]])
	{
		NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
		
		if (![defs boolForKey: kDefsKeysShouldRememberWindowPosition])
		{
		//	[self resetSavedWindowFrame];
			[defs setObject: @"" forKey: kDefsKeysMainWindowAutosaveFrameName];
		}
		else
		{
			[defs setObject: kDefsKeysMainWindowAutosaveFrameName forKey: kDefsKeysMainWindowAutosaveFrameName];
		//	[self resetSavedWindowFrame];
		}
		[defs synchronize];
		[mainWindowController updateFrameAutosave];
	}
}
		 
- (void) unregisterObservers
{
	NSUserDefaultsController *defc = [NSUserDefaultsController sharedUserDefaultsController];
	[defc removeObserver: self forKeyPath: nil];
}



#pragma mark -
#pragma mark window show/hide
- (void) showMainWindow
{
	if (!shouldShowWindow)
		return;
	
	if (!mainWindowController)
	{	
		mainWindowController = [[MainWindowController alloc] initWithWindowNibName: @"MainWindow"];

	}
	
	[mainWindowController showWindow: self];
}

- (void) hideMainWindow
{
	[[mainWindowController window] close];
	[mainWindowController release];
	mainWindowController = nil;
	if (![NSApp isHidden])
		[NSApp hide: self];
}


#pragma mark -
#pragma mark dock drop handling
- (void) processURLDrop: (NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error 
{
	[self setShouldShowWindow: NO];
    NSString * pboardString = [pboard stringForType:NSStringPboardType];
    
	NSURL *url = [NSURL URLWithString:pboardString];
	if (url != nil)
	{
		NSLog(@"dropped: %@",[url description]);
		FXDataCore *dataCore = [FXDataCore sharedCore];
		FXBookmark *bookmark = [dataCore insertNewObjectForEntityForName: @"Bookmark"];
		[bookmark setURL: [url description]];
		[bookmark setAdded: [NSDate date]];
		[bookmark setSiteTitle: @"penis!"];
		[bookmark setNote: @"LOL ICH BIN LOL!"];
		[dataCore saveContext];

		FXFetchSiteTitleOperation *to = [[FXFetchSiteTitleOperation alloc] init];
		[to setDelegate: self];
		[to setUrl: [bookmark URL]];
		[to setObjectID: [bookmark objectID]];
		[titleQueue addOperation: to];
	}
	
	[self hideMainWindow];
}

- (void) fetchSiteTitleOperationDidSuceed: (FXFetchSiteTitleOperation *) operation
{
	NSString *title = [[[operation title] copy] autorelease];
	if (title)
	{
		NSLog(@"setting title: %@", title);
		FXBookmark *bookmark = (FXBookmark *)[[[FXDataCore sharedCore] managedObjectContext] objectWithID: [operation objectID]];
		[bookmark setSiteTitle: title];
		[[FXDataCore sharedCore] saveContext];
	}

	
	[operation release];
}

- (void) fetchSiteTitleOperationDidFail: (FXFetchSiteTitleOperation *) operation
{
	NSLog(@"no title for url %@", [operation url]);
	[operation release];
}


#pragma mark -
#pragma mark dtor
- (void)dealloc 
{
	[self unregisterObservers];
	[mainWindowController release], mainWindowController = nil;
	
    [super dealloc];
}
@end

#pragma mark -
#pragma mark carbon event handler for key shortcuts
// Hot Key Handler to activate app
OSStatus MyHotKeyHandler(EventHandlerCallRef nextHandler,EventRef theEvent,	 void *userData)
{
	//[NSApp unhide:(id)userData];
	//[NSApp activate: NO];
	//	NSLog(@"hotkey pressed, bitch!");
	//NSLog(@"%@",(id)userData);
	//Do something once the key is pressed
	//	AppDelegate *d = (AppDelegate *)userData;
	//	[d openNewWindow: d];
	
	if ([NSApp isActive])
		[NSApp hide: nil];
	else
	{	
		[NSApp activateIgnoringOtherApps: YES];
		Read_Later_AppDelegate *d = (Read_Later_AppDelegate *)userData;
		[d setShouldShowWindow: YES];
		//	[d hideMainWindow];
		
		//		[d setShouldShowWindow: YES];
		
	}
	return noErr;
}


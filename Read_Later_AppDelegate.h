//
//  Read_Later_AppDelegate.h
//  Read Later
//
//  Created by jrk on 30/8/10.
//  Copyright flux forge 2010 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import "MainWindowController.h"
#import "PreferencesWindowController.h"


@interface Read_Later_AppDelegate : NSObject 
{
	MainWindowController *mainWindowController;
	BOOL shouldShowWindow;
	
	NSOperationQueue *titleQueue;
}

@property (readwrite, assign) BOOL shouldShowWindow;
- (BOOL) isRegistered;
- (void) showMainWindow;
- (void) hideMainWindow;

- (IBAction) openPreferencesWindow: (id) sender;

- (void) registerUserDefaults;
- (void) resetSavedWindowFrame;
- (void) registerObservers;

@end


//carbon :[
OSStatus MyHotKeyHandler(EventHandlerCallRef nextHandler,EventRef theEvent,	 void *userData);
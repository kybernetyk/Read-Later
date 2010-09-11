//
//  PreferencesWindowController.m
//  Read Later
//
//  Created by jrk on 3/9/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "PreferencesWindowController.h"
#import <Sparkle/Sparkle.h>

@implementation PreferencesWindowController
- (void)setupToolbar
{
	[self addView: generalPrefsView label: @"General"];
	[self addView: advancedPrefsView label: @"Advanced"];
	[self addView: updatesPrefsView label: @"Updates"];
	[self addView: registrationPrefsView label: @"Registration"];
	
	[self updateWindowWithRegistrationInfo];
}

- (IBAction) openMobileMeSyncingPrefs: (id) sender
{
	//[[NSWorkspace sharedWorkspace] openFile:@"/System/Library/PreferencePanes/MobileMe.prefPane"];	
	
	
	NSString *oastr = @"tell application \"System Preferences\"\nactivate\nset the current pane to pane id \"com.apple.preference.internet\"\nreveal anchor \"sync\" of pane id \"com.apple.preference.internet\"\nend tell\n";
	
	NSDictionary *scriptError = [[NSDictionary alloc] init]; 
	NSAppleScript *appleScript = [[NSAppleScript alloc] initWithSource:oastr]; 
	[appleScript executeAndReturnError:&scriptError];
	[appleScript release];
	[scriptError release];
}


#pragma mark -
#pragma mark Registration
- (void) updateWindowWithRegistrationInfo
{
	if ([[NSApp delegate] isRegistered])
	{
		[registeredToNameTextField setEditable: NO];
		[registeredToLicenseTextField setEditable: NO];
		
		[registerButton setEnabled: NO];
		[buyButton setTitle: @"Support"];
		
		//[howtoLabel setHidden: YES];
		[howtoLabel setStringValue: @"This copy of Read Later is registered. Thank you!"];
	}
	else
	{
		
		
	}
	
}


- (IBAction) handleRegisterButton: (id) sender
{
	NSLog(@"register!");
	
	
	[self updateWindowWithRegistrationInfo];
	
	if ([[NSApp delegate] isRegistered])
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

- (IBAction) handleBuyButton: (id) sender
{
	if ([[NSApp delegate] isRegistered])
		[[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: @"http://www.fluxforge.com/read-later/help/"]];
	else
		[[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: @"http://www.fluxforge.com/read-later/buy/"]];
	
}

#pragma mark -
#pragma mark updates
- (IBAction) checkForUpdates: (id) sender
{
	[[SUUpdater sharedUpdater] checkForUpdatesInBackground];
}

@end

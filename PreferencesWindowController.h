//
//  PreferencesWindowController.h
//  Read Later
//
//  Created by jrk on 3/9/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DBPrefsWindowController.h"

@interface PreferencesWindowController : DBPrefsWindowController
{
	IBOutlet NSView *generalPrefsView;
	IBOutlet NSView *advancedPrefsView;
	IBOutlet NSView *updatesPrefsView;
	IBOutlet NSView *registrationPrefsView;
	
	//registration
	IBOutlet NSTextField *registeredToNameTextField;
	IBOutlet NSTextField *registeredToLicenseTextField;
	IBOutlet NSButton *registerButton;
	IBOutlet NSButton *buyButton;
	
	IBOutlet NSTextField *howtoLabel;
	
}

//advanced
- (IBAction) openMobileMeSyncingPrefs: (id) sender;

//registration
- (IBAction) handleRegisterButton: (id) sender;
- (IBAction) handleBuyButton: (id) sender;

//updates
- (IBAction) checkForUpdates: (id) sender;

- (void) updateWindowWithRegistrationInfo;
@end

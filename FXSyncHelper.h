//
//  FXSyncHelper.h
//  Read Later
//
//  Created by jrk on 1/9/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SyncServices/SyncServices.h>

@interface FXSyncHelper : NSObject <NSPersistentStoreCoordinatorSyncing>
{
	BOOL hasSyncedOnce;
}
@property (readonly, assign) BOOL hasSyncedOnce;

- (id)initWithShouldPull: (BOOL) shouldPull error:(NSError**)error;
- (BOOL)performSync:(NSError**)err;

@end

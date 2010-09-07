//
//  JSDataCore.h
//  Currency2
//
//  Created by jrk on 13/4/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FXSyncHelper.h"

@interface FXDataCore : NSObject 
{
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;

	FXSyncHelper *syncHelper;
	NSTimer *syncTimer;
}
+(FXDataCore *) sharedCore;


@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly) FXSyncHelper *syncHelper;

- (BOOL) saveContext;
- (NSString *)applicationSupportDirectory;

- (id) insertNewObjectForEntityForName: (NSString *) entityName;

@end

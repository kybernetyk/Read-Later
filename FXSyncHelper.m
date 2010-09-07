//
//  FXSyncHelper.m
//  Read Later
//
//  Created by jrk on 1/9/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "FXSyncHelper.h"
#import "FXDataCore.h"

@interface FXSyncHelper()

- (ISyncClient*)syncClient:(NSError**)error;

@end

@implementation FXSyncHelper
@synthesize hasSyncedOnce;
static BOOL chatty = YES;

//START:registerSyncClient
- (id)initWithShouldPull: (BOOL) shouldPull error:(NSError**)error;
{
	if (!(self = [super init])) 
		return nil;

	hasSyncedOnce = NO;
	
	ISyncClient *client = [self syncClient:error];
	if (!client) 
	{
		[self autorelease];
		return nil;
	}
	
	if (shouldPull)
	{
		NSLog(@"client will pull: %@",[client supportedEntityNames]);
		[client setShouldReplaceClientRecords: YES forEntityNames: [client supportedEntityNames]];
	}
	
	
	[client setSyncAlertHandler:self selector:@selector(client:mightWantToSyncEntityNames:)];
	
	if (![self performSync:error]) 
	{
		[self autorelease];
		return nil;
	}
	
	return self;
}
//END:registerSyncClient

#pragma mark Sync Services Methods
#pragma mark -

- (void)client:(ISyncClient*)client mightWantToSyncEntityNames:(NSArray*)names
{
	NSLog(@"mightWantToSyncEntityNames: %@",names);
	[[FXDataCore sharedCore] saveContext];
}

- (BOOL)performSync:(NSError**)err;
{
	ISyncClient *client = [self syncClient:err];
	if (!client) return NO;
	
	NSLog(@"Starting sync");
	NSPersistentStoreCoordinator *store = [[FXDataCore sharedCore] persistentStoreCoordinator];
	return [store syncWithClient:client
					inBackground:YES
						 handler:self
						   error:err];
}
//END:performSync

//START:syncClientAlreadyRegistered
- (ISyncClient*)syncClient:(NSError**)error
{
	NSString *ident = [[NSBundle mainBundle] bundleIdentifier];
	NSLog(@"ident: %@",ident);
	ISyncClient *client;
	NSDictionary *dict;
	ISyncManager *manager = [ISyncManager sharedManager];
	NSBundle *mainBundle = [NSBundle mainBundle];
	
	@try {
		client = [manager clientWithIdentifier:ident];
		
		
		NSLog(@"client: %@",client);
		if (client) 
			return client;
		NSString *path = [mainBundle pathForResource:@"SyncSchema" ofType:@"syncschema"];

		if (![manager registerSchemaWithBundlePath:path]) 
		{
			NSString *err = NSLocalizedString(@"Failed to register the schema",
											  @"Failed to register the schema error message");
			dict = [NSDictionary dictionaryWithObject:err forKey:NSLocalizedDescriptionKey];
			*error = [NSError errorWithDomain:@"PragProg"
										 code:8001
									 userInfo:dict];
			return nil;
		}
		path = [mainBundle pathForResource:@"ClientDescription"
									ofType:@"plist"];
		client = [manager registerClientWithIdentifier:ident 
								   descriptionFilePath:path];

		[client setShouldSynchronize:YES 
				   withClientsOfType:ISyncClientTypeApplication];
		[client setShouldSynchronize:YES
				   withClientsOfType:ISyncClientTypeDevice];
		[client setShouldSynchronize:YES 
				   withClientsOfType:ISyncClientTypeServer];
		[client setShouldSynchronize:YES 
				   withClientsOfType:ISyncClientTypePeer];
	} @catch (NSException *exception) {
		dict = [NSDictionary dictionaryWithObject:[exception reason]
										   forKey:NSLocalizedDescriptionKey];
		*error = [NSError errorWithDomain:@"PragProg"
									 code:8002
								 userInfo:dict];
		return nil;
	}
	NSLog(@"%@",client);
	
	return client;
}
//END:syncClientWhatBlewUp

#pragma mark NSPersistentStoreCoordinatorSyncing
#pragma mark -

- (NSArray*)managedObjectContextsToMonitorWhenSyncingPersistentStoreCoordinator:(NSPersistentStoreCoordinator*)coordinator
{
	NSLog(@"%@:%s entered", [self class], _cmd);
	return [NSArray arrayWithObject:[[FXDataCore sharedCore] managedObjectContext]];
}

- (NSArray*)managedObjectContextsToReloadAfterSyncingPersistentStoreCoordinator:(NSPersistentStoreCoordinator*)coordinator
{
	NSLog(@"%@:%s entered", [self class], _cmd);
	return [NSArray arrayWithObject:[[FXDataCore sharedCore] managedObjectContext]];
}

//START: didFinishSyncSession
- (void)persistentStoreCoordinator:(NSPersistentStoreCoordinator*)coordinator 
              didFinishSyncSession:(ISyncSession*)session
{
	NSManagedObjectContext *moc = [[FXDataCore sharedCore] managedObjectContext];
//	NSSet *deleted = [moc deletedObjects];
	NSMutableSet *updated = [NSMutableSet setWithSet:[moc insertedObjects]];
	[updated unionSet:[moc updatedObjects]];
	
	hasSyncedOnce = YES;
	
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center postNotification: [NSNotification notificationWithName:@"SyncHelperDidFinishSyncSession" object: self]];
	
/*	NSError *error = nil;
	[delegate updateMetadataForObjects:updated 
					 andDeletedObjects:deleted 
								 error:&error];
	if (error) {
		NSLog(@"%@:%s error updating after sync: %@", [self class], _cmd, error);
	}
	[moc save:&error];
	if (error) {
		NSLog(@"%@:%s error saving after sync: %@", [self class], _cmd, error);
	}*/
	
	NSLog(@"did finish sync session: %@", updated);
}
//END: didFinishSyncSession

- (ISyncChange*)persistentStoreCoordinator:(NSPersistentStoreCoordinator*)coordinator 
                           willApplyChange:(ISyncChange*)change 
                           toManagedObject:(NSManagedObject*)managedObject 
                             inSyncSession:(ISyncSession*)session
{
	NSLog(@"pull %@", [change description]);
	return change;
}

- (NSDictionary*)persistentStoreCoordinator:(NSPersistentStoreCoordinator*)coordinator 
                             willPushRecord:(NSDictionary*)record 
                           forManagedObject:(NSManagedObject*)managedObject 
                              inSyncSession:(ISyncSession*)session
{
	if (chatty) NSLog(@"%@:%s entered", [self class], _cmd);
	return record;
}

- (void)persistentStoreCoordinator:(NSPersistentStoreCoordinator*)coordinator 
                    didApplyChange:(ISyncChange*)change 
                   toManagedObject:(NSManagedObject*)managedObject 
                     inSyncSession:(ISyncSession*)session
{
	if (chatty) NSLog(@"%@:%s entered", [self class], _cmd);
}

- (void)persistentStoreCoordinator:(NSPersistentStoreCoordinator*)coordinator 
              didCancelSyncSession:(ISyncSession*)session 
                             error:(NSError*)error
{
	NSLog(@"%@:%s entered", [self class], _cmd);
}

- (void)persistentStoreCoordinator:(NSPersistentStoreCoordinator*)coordinator 
                  didCommitChanges:(NSDictionary*)changes 
                     inSyncSession:(ISyncSession*)session
{
	if (chatty) NSLog(@"%@:%s entered", [self class], _cmd);
}

- (void)persistentStoreCoordinator:(NSPersistentStoreCoordinator*)coordinator 
       didPullChangesInSyncSession:(ISyncSession*)session
{
	if (chatty) NSLog(@"%@:%s entered", [self class], _cmd);
}

- (void)persistentStoreCoordinator:(NSPersistentStoreCoordinator*)coordinator 
       didPushChangesInSyncSession:(ISyncSession*)session
{
	if (chatty) NSLog(@"%@:%s entered", [self class], _cmd);
}

- (BOOL)persistentStoreCoordinator:(NSPersistentStoreCoordinator*)coordinator 
    willDeleteRecordWithIdentifier:(NSString*)identifier 
                     inSyncSession:(ISyncSession*)session
{
	if (chatty) NSLog(@"%@:%s entered", [self class], _cmd);
	return YES;
}

- (void)persistentStoreCoordinator:(NSPersistentStoreCoordinator*)coordinator 
      willPullChangesInSyncSession:(ISyncSession*)session
{
	if (chatty) NSLog(@"%@:%s entered", [self class], _cmd);
}

- (void)persistentStoreCoordinator:(NSPersistentStoreCoordinator*)coordinator 
      willPushChangesInSyncSession:(ISyncSession*)session
{
	if (chatty) NSLog(@"%@:%s entered", [self class], _cmd);
}

- (BOOL)persistentStoreCoordinatorShouldStartSyncing:(NSPersistentStoreCoordinator*)coordinator
{
	if (chatty) NSLog(@"%@:%s entered", [self class], _cmd);
	return YES;
}


@end
//
//  JSDataCore.m
//  Currency2
//
//  Created by jrk on 13/4/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "FXDataCore.h"
#import "FXSyncHelper.h"

@implementation FXDataCore
@synthesize syncHelper;

static FXDataCore *sharedSingleton = nil;


+(FXDataCore*)sharedCore 
{
    @synchronized(self) 
	{
        if (sharedSingleton == nil) 
		{
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedSingleton;
}


+(id)allocWithZone:(NSZone *)zone 
{
    @synchronized(self) 
	{
        if (sharedSingleton == nil) 
		{
            sharedSingleton = [super allocWithZone:zone];
            return sharedSingleton;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}


-(void)dealloc 
{
    [super dealloc];
}

-(id)copyWithZone:(NSZone *)zone 
{
    return self;
}


-(id)retain 
{
    return self;
}


-(NSUInteger)retainCount 
{
    return UINT_MAX;  //denotes an object that cannot be release
}


-(void)release 
{
    //do nothing    
}


-(id)autorelease 
{
    return self;    
}

- (void) reset
{
}


-(id)init 
{
    self = [super init];
    sharedSingleton = self;
	
	[self reset];
	
    return self;
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext 
{
    if (managedObjectContext) return managedObjectContext;
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) 
	{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator: coordinator];
	
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel 
{
    if (managedObjectModel) 
	{
		return managedObjectModel;
	}
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator 
{
	
    if (persistentStoreCoordinator)
	{
		return persistentStoreCoordinator;
	}
	
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) 
	{
        NSAssert(NO, @"Managed object model is nil");
		//    NSLog(@"%@:%s No model to generate a store from", [self class], _cmd);
        return nil;
    }
	
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *applicationSupportDirectory = [self applicationSupportDirectory];
    NSError *error = nil;
    
    if ( ![fileManager fileExistsAtPath:applicationSupportDirectory isDirectory:NULL] ) {
		if (![fileManager createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSAssert(NO, ([NSString stringWithFormat:@"Failed to create App Support directory %@ : %@", applicationSupportDirectory,error]));
            NSLog(@"Error creating application support directory at %@ : %@",applicationSupportDirectory,error);
            return nil;
		}
    }
    
    NSURL *url = [NSURL fileURLWithPath: [applicationSupportDirectory stringByAppendingPathComponent: @"storedata"]];
	
	BOOL shoudPull = NO;
	if (![fileManager fileExistsAtPath: [applicationSupportDirectory stringByAppendingPathComponent: @"storedata"]])
	{
		shoudPull = YES;
	}
		
	
	//START:turnOnAutomaticMigration
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:[NSNumber numberWithBool:YES] 
			 forKey:NSMigratePersistentStoresAutomaticallyOption];
	
	
	
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: mom];
	NSPersistentStore *store = [persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType 
																		configuration:nil 
																				  URL:url 
																			  options: dict 
																				error:&error];
    if (!store)
	{
		//END:turnOnAutomaticMigration
		NSDictionary *ui = [error userInfo];
		if (ui) 
		{
			NSLog(@"%@:%s %@", [self class], _cmd, [error localizedDescription]);
			for (NSError *suberror in [ui valueForKey:NSDetailedErrorsKey]) 
			{
				NSLog(@"\t%@", [suberror localizedDescription]);
			}
		} 
		else 
		{
			NSLog(@"%@:%s %@", [self class], _cmd, [error localizedDescription]);
		}
		NSAlert *alert = [[NSAlert alloc] init];
		[alert setAlertStyle:NSCriticalAlertStyle];
		[alert setMessageText:@"Unable to load the bookmark database."];
		NSString *msgText = nil;
		msgText = [NSString stringWithFormat:@"The bookmark database %@%@%@\n%@",
				   @"is either corrupt or was created by a newer ",
				   @"version of Read Later.  Please contact ",
				   @"support to assist with this error.\n\nError: ",
				   [error localizedDescription]];
		[alert setInformativeText:msgText];
		[alert addButtonWithTitle:@"Quit"];
		[alert runModal];
		[alert release];
		
        [persistentStoreCoordinator release], persistentStoreCoordinator = nil;

		exit(1);
    }

	NSString *fss = @"store.fastsyncstore";
	fss = [[self applicationSupportDirectory] stringByAppendingPathComponent:fss];
	NSURL *fsdURL = [NSURL fileURLWithPath:fss];
	
	[persistentStoreCoordinator setStoresFastSyncDetailsAtURL: fsdURL forPersistentStore: store];
	
	syncHelper = [[FXSyncHelper alloc] initWithShouldPull: shoudPull error:&error];
	if (!syncHelper) 
	{
		NSLog(@"%@:%s presenting error sync helper failed", [self class], _cmd);
		NSDictionary *ui = [error userInfo];
		for (NSError *suberror in [ui valueForKey:NSDetailedErrorsKey]) 
		{
			NSLog(@"subError: %@", suberror);
		}
		[NSApp presentError:error];
	}
	error = nil;
	
	
    return persistentStoreCoordinator;
}

- (BOOL) saveContextWithDelayedSync
{
	
	NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) 
	{
		// NSLog(@"%@:%s unable to commit editing before saving", [self class], _cmd);
    }
	
    if (![[self managedObjectContext] save:&error]) 
	{
        [[NSApplication sharedApplication] presentError:error];
		return NO;
    }
	
	[syncTimer invalidate];
	syncTimer = nil;
	
	syncTimer = [NSTimer scheduledTimerWithTimeInterval: 10.0 target: self selector: @selector(kickOffSync:) userInfo: nil repeats: NO];
	
	return YES;
	
}

- (BOOL) saveContextWithInstantSync
{
	
	NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) 
	{
		// NSLog(@"%@:%s unable to commit editing before saving", [self class], _cmd);
    }
	
    if (![[self managedObjectContext] save:&error]) 
	{
        [[NSApplication sharedApplication] presentError:error];
		return NO;
    }
	
	[syncTimer invalidate];
	syncTimer = nil;
	
	[self kickOffSync: nil];
	
	return YES;
	
}


- (void) kickOffSync: (id) timer
{
	syncTimer = nil;
	NSLog(@"%@:%s Performing sync", [self class], _cmd);
	NSError *error;
	if (![syncHelper performSync:&error]) 
	{
		[[NSApplication sharedApplication] presentError:error];
	}
}

#pragma mark -
#pragma mark Application's Support directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationSupportDirectory 
{
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"Read_Later"];
}

#pragma mark -
#pragma mark object insertion
- (id) insertNewObjectForEntityForName: (NSString *) entityName
{
	return [NSEntityDescription insertNewObjectForEntityForName: entityName inManagedObjectContext: [self managedObjectContext]];
	
}

@end

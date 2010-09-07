//
//  FXFetchSiteTitleOperation.h
//  Read Later
//
//  Created by jrk on 6/9/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FXFetchSiteTitleOperation : NSOperation
{
	NSString *url;
	NSString *title;
	NSManagedObjectID *objectID;
	id delegate;
}

@property (readwrite, copy) NSString *url;
@property (readwrite, copy) NSString *title;
@property (readwrite, assign) id delegate;
@property (readwrite, retain) NSManagedObjectID *objectID;
@end

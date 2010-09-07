//
//  FXBookmark.h
//  Read Later
//
//  Created by jrk on 30/8/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FXBookmark : NSManagedObject 
{

}

@property (nonatomic, retain) NSString *URL;
@property (nonatomic, retain) NSNumber *visited;
@property (nonatomic, retain) NSDate *added;
@property (nonatomic, retain) NSNumber *lastVisited;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSString * siteTitle;



@end


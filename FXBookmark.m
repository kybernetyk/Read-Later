//
//  FXBookmark.m
//  Read Later
//
//  Created by jrk on 30/8/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "FXBookmark.h"


@implementation FXBookmark
@dynamic URL;
@dynamic visited;
@dynamic added;
@dynamic lastVisited;
@dynamic note;
@dynamic siteTitle;

- (NSString *) headline
{
	if (![self siteTitle] || [[self siteTitle] length] == 0)
	{
		return [NSString stringWithFormat: @"%@",[self URL]];
	}
	return [NSString stringWithFormat: @"%@ (%@)", [self siteTitle], [self URL]];
}

@end

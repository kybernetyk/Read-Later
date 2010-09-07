//
//  FXFetchSiteTitleOperation.m
//  Read Later
//
//  Created by jrk on 6/9/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "FXFetchSiteTitleOperation.h"
#import "NSString+Slice.h"

@implementation FXFetchSiteTitleOperation
@synthesize url;
@synthesize title;
@synthesize delegate;
@synthesize objectID;

- (void) messageDelegateSuccess
{
	if ([delegate respondsToSelector: @selector(fetchSiteTitleOperationDidSuceed:)])
	{
		[delegate performSelectorOnMainThread:  @selector(fetchSiteTitleOperationDidSuceed:) withObject: self waitUntilDone: NO];
	}	
}

- (void) messageDelegateFailure
{
	if ([delegate respondsToSelector: @selector(fetchSiteTitleOperationDidFail:)])
	{
		[delegate performSelectorOnMainThread:  @selector(fetchSiteTitleOperationDidFail:) withObject: self waitUntilDone: NO];
	}
	
}

- (void) main
{
	if (!url)
	{
		NSLog(@"no url given!");
		[self messageDelegateFailure];
		return;
	}
	
	NSURL *_url = [NSURL URLWithString: url];
	if (!_url)
	{
		NSLog(@"invalid url: %@", url);
		[self messageDelegateFailure];
		return;
	}
	
	NSString *text = [NSString stringWithContentsOfURL: _url];
	if (!text)
	{
		NSLog(@"could not retrieve site ...");
		[self messageDelegateFailure];
		return;
	}
	
	NSRange s = [text rangeOfString: @"<title>" options: NSCaseInsensitiveSearch];
	if (s.location == NSNotFound)
	{
		NSLog(@"title start not found");
		[self messageDelegateFailure];
		return;
	}
	NSUInteger title_start = s.location + s.length;
	
	s.location = title_start;
	s.length = [text length] - title_start;
	NSRange e = [text rangeOfString: @"</title>" options: NSCaseInsensitiveSearch range: s];
	if (e.location == NSNotFound)
	{
		NSLog(@"title end not found");
		[self messageDelegateFailure];
		return;
	}
	NSString *tit = [text stringBySlicingFrom: s.location to: e.location-1];
	if (!tit)
	{
		NSLog(@"could not extract title :[");
		[self messageDelegateFailure];
		return;
	}
	
	[self setTitle: tit];
	NSLog(@"self title: %@", [self title]);
	[self messageDelegateSuccess];
}

@end

//
//  RRMOperationPOP3.m
//  rrmail
//
//  Created by Yoann Gini on 07/08/13.
//  Copyright (c) 2013 Yoann Gini. All rights reserved.
//

#import "RRMOperationPOP3.h"
#import "RRMConstants.h"

@interface RRMOperationPOP3 ()
{
	NSDictionary *_serverConfig;
	NSDictionary *_userSettings;
}

@end

@implementation RRMOperationPOP3

#pragma mark Object lifecycle

- (id)initWithServerConfiguration:(NSDictionary*)serverConfig andUserSettings:(NSDictionary*)userSettings
{
    self = [super init];
    if (self) {
        _serverConfig = [serverConfig copy];
		_userSettings = [userSettings copy];
    }
    return self;
}

- (void)dealloc
{
    [_serverConfig release], _serverConfig = nil;
	[_userSettings release], _userSettings = nil;
    [super dealloc];
}

#pragma mark RRMOperation

- (void)operationGo {
	
	NSLog(@"Get e-mail from %@ for %@ and redirect it to %@ for %@", [_serverConfig objectForKey:kRRMSourceServerAddressKey], [_userSettings objectForKey:kRRMSourceServerLoginKey], [_userSettings objectForKey:kRRMTargetServerKey], [_userSettings objectForKey:kRRMTargetServerAccountKey]);
	
	[self operationDone];
	// Start async operation and when it's done, call [self operationDone]; from anywhere in this instance.
}

@end

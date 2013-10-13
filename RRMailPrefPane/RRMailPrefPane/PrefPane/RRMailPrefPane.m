//
//  RRMailPrefPane.m
//  RRMailPrefPane
//
//  Created by Yoann Gini on 13/10/13.
//  Copyright (c) 2013 iNig-Services. All rights reserved.
//

#import "RRMailPrefPane.h"

#import <SecurityInterface/SFAuthorizationView.h>

#import "RRMPrefPaneMainViewController.h"
#import "RRMailCTL.h"

@interface RRMailPrefPane ()

@property (strong) RRMPrefPaneMainViewController *mainViewController;

@end

@implementation RRMailPrefPane

#pragma mark - PrefPane

- (void)mainViewDidLoad
{
	AuthorizationItem authItems = {kAuthorizationRightExecute, 0, NULL, 0};
    AuthorizationRights authRights = {1, &authItems};
    [self.authorizationView setAuthorizationRights:&authRights];
	[self.authorizationView setAutoupdate:YES];
	self.authorizationView.delegate = self;
	
	[self.authorizationView updateStatus:self]; // Shouldn't be needed with setAutoupdate:YES but without that, the lockpad is display only after the first mouse over
	
	self.mainViewController = [[RRMPrefPaneMainViewController alloc] initWithNibName:@"RRMPrefPaneMainViewController"
																			  bundle:[NSBundle bundleForClass:[RRMPrefPaneMainViewController class]]];
}

#pragma mark - SFAuthorizationView

- (void)authorizationViewDidAuthorize:(SFAuthorizationView *)view
{
	[RRMailCTL sharedInstance].authorization = view.authorization;

	NSRect frame = self.mainViewController.view.frame;
	frame.origin.x = 20;
	frame.origin.y = self.view.frame.size.height - frame.size.height;
	self.mainViewController.view.frame = frame;
	
	[self.view addSubview:self.mainViewController.view];
	[self.helperTextField setHidden:YES];
}

- (void)authorizationViewDidDeauthorize:(SFAuthorizationView *)view
{
	[self.helperTextField setHidden:NO];
	[self.mainViewController.view removeFromSuperview];
	
	[RRMailCTL sharedInstance].authorization = nil;
}

@end

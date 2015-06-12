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

#import <GHUpdate/GHUpdate.h>

@interface RRMailPrefPane ()

@property (strong) RRMPrefPaneMainViewController *mainViewController;

@end

@implementation RRMailPrefPane

#pragma mark - PrefPane

- (void)mainViewDidLoad
{
    NSDictionary *appInfos = [[NSBundle bundleWithIdentifier:@"com.inig-services.RRMail"] infoDictionary];
    
    NSString *repos = [appInfos objectForKey:@"GHUpdateRepos"];
    NSString *owner = [appInfos objectForKey:@"GHUpdateOwner"];
    NSString *version = [appInfos objectForKey:@"CFBundleShortVersionString"];
    
    [GHUpdater checkAndUpdateFromRepos:repos by:owner withCurrentVersion:version];

	
	AuthorizationItem authItems = {kAuthorizationRightExecute, 0, NULL, 0};
    AuthorizationRights authRights = {1, &authItems};
    [self.authorizationView setAuthorizationRights:&authRights];
	[self.authorizationView setAutoupdate:YES];
	self.authorizationView.delegate = self;
	
	[self.authorizationView updateStatus:self]; // Shouldn't be needed with setAutoupdate:YES but without that, the lockpad is display only after the first mouse over
}

- (IBAction)openInigServicesWebPage:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.inig-services.com/"]];
}

- (IBAction)openPaypalWebPage:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=3VYYYK2GCCTAA"]];
}

#pragma mark - SFAuthorizationView

- (void)authorizationViewDidAuthorize:(SFAuthorizationView *)view
{
	[RRMailCTL sharedInstance].authorization = view.authorization;

	self.mainViewController = [[RRMPrefPaneMainViewController alloc] initWithNibName:@"RRMPrefPaneMainViewController"
																			  bundle:[NSBundle bundleForClass:[RRMPrefPaneMainViewController class]]];

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
	self.mainViewController = nil;
	
	[RRMailCTL sharedInstance].authorization = nil;
}

@end

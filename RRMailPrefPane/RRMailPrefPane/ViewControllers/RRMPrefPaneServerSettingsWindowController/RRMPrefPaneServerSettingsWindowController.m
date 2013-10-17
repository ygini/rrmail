//
//  RRMPrefPaneServerSettingsWindowController.m
//  RRMailPrefPane
//
//  Created by Yoann Gini on 13/10/13.
//  Copyright (c) 2013 iNig-Services. All rights reserved.
//

#import "RRMPrefPaneServerSettingsWindowController.h"

#import <RRMConstants.h>

@interface RRMPrefPaneServerSettingsWindowController ()

- (IBAction)OKAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

@end

@implementation RRMPrefPaneServerSettingsWindowController

+ (instancetype)prepareServerSettingsWindowWithSourceInfo:(NSDictionary*)sourceInfo
{
	RRMPrefPaneServerSettingsWindowController *window = [[self alloc] initWithWindowNibName:@"RRMPrefPaneServerSettingsWindowController"];
	
	if (sourceInfo) {
		window.serverInfo = [sourceInfo mutableCopy];
	}
	else {
		window.serverInfo = [@{
							   kRRMSourceServerAddressKey: @"mail.example.com",
							   kRRMSourceServerMaxConcurrentOperationsKey: @10,
							   kRRMSourceServerTCPPortKey: @993,
							   kRRMSourceServerTypeKey: kRRMSourceServerTypeIMAPValue,
							   kRRMSourceServerRequireSSLKey: @YES
							  } mutableCopy];
	}
	
	return window;
}

- (IBAction)OKAction:(id)sender {
	[NSApp endSheet:self.window returnCode:NSOKButton];
}

- (IBAction)cancelAction:(id)sender {
	[NSApp endSheet:self.window returnCode:NSCancelButton];
}
@end

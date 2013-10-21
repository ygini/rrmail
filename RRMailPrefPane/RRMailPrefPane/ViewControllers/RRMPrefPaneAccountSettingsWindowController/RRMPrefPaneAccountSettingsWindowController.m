//
//  RRMPrefPaneAccountSettingsWindowController.m
//  RRMailPrefPane
//
//  Created by Florian BONNIEC on 10/18/13.
//  Copyright (c) 2013 iNig-Services. All rights reserved.
//

#import "RRMPrefPaneAccountSettingsWindowController.h"

#import <RRMConstants.h>

@interface RRMPrefPaneAccountSettingsWindowController ()

- (IBAction)OKAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

@end

@implementation RRMPrefPaneAccountSettingsWindowController

+ (instancetype)prepareAccountSettingsWindowWithSourceInfo:(NSDictionary*)sourceInfo
{
	RRMPrefPaneAccountSettingsWindowController *window = [[self alloc] initWithWindowNibName:@"RRMPrefPaneAccountSettingsWindowController"];
	
	if (sourceInfo) {
		window.accountInfo = [sourceInfo mutableCopy];
	}
	else {
		window.accountInfo = [@{
							   kRRMSourceServerLoginKey: @"alice@example.com",
							   kRRMSourceServerPasswordKey: @"SourcePassword",
							   kRRMTargetServerAccountKey: @"alice@exemple.fr",
							   kRRMTargetServerKey: @"mail.exemple.fr",
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

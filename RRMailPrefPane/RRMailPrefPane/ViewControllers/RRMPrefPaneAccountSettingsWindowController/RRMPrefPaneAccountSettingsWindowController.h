//
//  RRMPrefPaneAccountSettingsWindowController.h
//  RRMailPrefPane
//
//  Created by Florian BONNIEC on 10/18/13.
//  Copyright (c) 2013 iNig-Services. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RRMPrefPaneAccountSettingsWindowController : NSWindowController

@property (strong) IBOutlet NSMutableDictionary *accountInfo;

+ (instancetype)prepareAccountSettingsWindowWithSourceInfo:(NSMutableDictionary*)sourceInfo;

@end

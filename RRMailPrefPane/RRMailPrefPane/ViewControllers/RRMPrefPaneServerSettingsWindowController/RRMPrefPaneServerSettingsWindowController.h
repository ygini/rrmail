//
//  RRMPrefPaneServerSettingsWindowController.h
//  RRMailPrefPane
//
//  Created by Yoann Gini on 13/10/13.
//  Copyright (c) 2013 iNig-Services. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RRMPrefPaneServerSettingsWindowController : NSWindowController

@property (strong) IBOutlet NSMutableDictionary *serverInfo;

+ (instancetype)prepareServerSettingsWindowWithSourceInfo:(NSMutableDictionary*)sourceInfo;
@end

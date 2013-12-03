//
//  RRMailPrefPane.h
//  RRMailPrefPane
//
//  Created by Yoann Gini on 13/10/13.
//  Copyright (c) 2013 iNig-Services. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>

@class SFAuthorizationView;

@interface RRMailPrefPane : NSPreferencePane
@property (strong) IBOutlet NSView *view;
@property (strong) IBOutlet SFAuthorizationView *authorizationView;
@property (strong) IBOutlet NSTextField *helperTextField;

- (void)mainViewDidLoad;

- (IBAction)openInigServicesWebPage:(id)sender;
- (IBAction)openPaypalWebPage:(id)sender;
@end

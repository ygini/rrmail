//
//  RRMailPrefsPane.h
//  RRMailPrefsPane
//
//  Created by Florian BONNIEC on 9/2/13.
//  Copyright (c) 2013 Florian BONNIEC. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>
#import <SecurityInterface/SFAuthorizationView.h>

#import "DisplayInfoViewController.h"
#import "AddSourceServerViewController.h"
#import "AddSourceServerAccountViewController.h"


@interface RRMailPrefsPane : NSPreferencePane <DisplayInfoViewControllerDelegate>
{
    IBOutlet SFAuthorizationView *authView;
}

- (void)mainViewDidLoad;

- (BOOL)isUnlocked;

@end

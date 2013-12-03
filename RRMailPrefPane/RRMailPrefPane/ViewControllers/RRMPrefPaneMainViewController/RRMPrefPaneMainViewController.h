//
//  RRMPrefPaneMainViewController.h
//  RRMailPrefPane
//
//  Created by Yoann Gini on 13/10/13.
//  Copyright (c) 2013 iNig-Services. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "INIGViewController.h"
#import "RRMailCTL.h"

@interface RRMPrefPaneMainViewController : INIGViewController

@property (strong) IBOutlet RRMailCTL *rrmailctl;

@end

//
//  RRMPrefPaneMainViewController.m
//  RRMailPrefPane
//
//  Created by Yoann Gini on 13/10/13.
//  Copyright (c) 2013 iNig-Services. All rights reserved.
//

#import "RRMPrefPaneMainViewController.h"

@interface RRMPrefPaneMainViewController ()

@end

@implementation RRMPrefPaneMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(void)viewWillLoad
{
	self.rrmailctl = [RRMailCTL sharedInstance];
}

@end

//
//  ConfirmDeleteViewController.m
//  RRMailPrefsPane
//
//  Created by Florian BONNIEC on 9/10/13.
//  Copyright (c) 2013 iNig-Services. All rights reserved.
//

#import "ConfirmDeleteViewController.h"

@interface ConfirmDeleteViewController ()

@end

@implementation ConfirmDeleteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (IBAction)actionDelete:(id)sender {
    [self.delegate confirmDeleteAccount:self isSourceServerAddress:self.isSourceServerAddress];
}

- (IBAction)actionCancel:(id)sender {
    [self.delegate cancelDeleteAccount:self];
}
@end

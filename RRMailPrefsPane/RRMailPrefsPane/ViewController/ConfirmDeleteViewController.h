//
//  ConfirmDeleteViewController.h
//  RRMailPrefsPane
//
//  Created by Florian BONNIEC on 9/10/13.
//  Copyright (c) 2013 Florian BONNIEC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ConfirmDeleteViewController;

@protocol ConfirmDeleteViewControllerDelegate <NSObject>

- (void)confirmDeleteAccount:(ConfirmDeleteViewController *)controller isSourceServerAddress:(BOOL)boolValue;
- (void)cancelDeleteAccount:(ConfirmDeleteViewController *)controller;

@end

@interface ConfirmDeleteViewController : NSViewController

@property (nonatomic, weak) id <ConfirmDeleteViewControllerDelegate> delegate;

@property (nonatomic, assign) BOOL isSourceServerAddress;
@property (weak) IBOutlet NSButton *buttonOk;

- (IBAction)actionDelete:(id)sender;
- (IBAction)actionCancel:(id)sender;

@end

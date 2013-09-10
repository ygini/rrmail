//
//  AddSourceServerAccountViewController.h
//  RRMailPrefsPane
//
//  Created by Florian BONNIEC on 9/4/13.
//  Copyright (c) 2013 Florian BONNIEC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AddSourceServerAccountViewController;

@protocol AddSourceServerAccountViewControllerDelegate <NSObject>
- (void)addSourceServerAccountViewController:(AddSourceServerAccountViewController *)controller;
- (void)cancelSourceServerAccountViewController:(AddSourceServerAccountViewController *)controller;

@end

@interface AddSourceServerAccountViewController : NSViewController

@property (nonatomic, weak) id <AddSourceServerAccountViewControllerDelegate> delegate;

@property (nonatomic, assign) NSMutableArray * _serverAccountList;
@property (nonatomic, assign) NSMutableDictionary * _userConfig;

- (IBAction)actionAddSourceServerAccount:(id)sender;
- (IBAction)actionCancel:(id)sender;

@property (weak) IBOutlet NSTextField *textFieldSSLogin;
@property (weak) IBOutlet NSSecureTextField *textFieldSSPassword;
@property (weak) IBOutlet NSTextField *textFieldTSAccount;
@property (weak) IBOutlet NSTextField *textFieldTSAddress;

- (void)updateData;

@end

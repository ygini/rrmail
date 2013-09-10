//
//  AddSourceServerViewController.h
//  RRMailPrefsPane
//
//  Created by Florian BONNIEC on 9/4/13.
//  Copyright (c) 2013 Florian BONNIEC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AddSourceServerViewController;

@protocol AddSourceServerViewControllerDelegate <NSObject>
- (void)addSourceServerViewController:(AddSourceServerViewController *)controller;
- (void)cancelSourceServerViewController:(AddSourceServerViewController *)controller;

@end

@interface AddSourceServerViewController : NSViewController

@property (nonatomic, weak) id <AddSourceServerViewControllerDelegate> delegate;

@property (nonatomic, assign) NSMutableArray * _serverConfigList;
@property (nonatomic, assign) NSMutableDictionary * _serverConfig;

- (IBAction)actionAddSourceServer:(id)sender;
- (IBAction)actionCancel:(id)sender;

@property (weak) IBOutlet NSTextField *textFieldSSAddress;
@property (weak) IBOutlet NSPopUpButton *buttonSSRequireSSL;
@property (weak) IBOutlet NSPopUpButton *buttonSSMaxConcurrentOperations;
@property (weak) IBOutlet NSPopUpButton *buttonSSType;
@property (weak) IBOutlet NSTextField *textFieldSSTCPPort;

- (void)updateData;

@end

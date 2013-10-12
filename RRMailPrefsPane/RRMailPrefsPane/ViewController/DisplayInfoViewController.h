//
//  DisplayInfoViewController.h
//  RRMailPrefsPane
//
//  Created by Florian BONNIEC on 9/4/13.
//  Copyright (c) 2013 iNig-Services. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AddSourceServerViewController.h"
#import "AddSourceServerAccountViewController.h"
#import "ConfirmDeleteViewController.h"
#import "OnOffSwitchControlCell.h"


@class DisplayInfoViewController;

@protocol DisplayInfoViewControllerDelegate <NSObject>
- (BOOL)displayInfoViewController:(DisplayInfoViewController *)controller callRRMailConfigWithParameters:(NSMutableArray *)parameters;

@end

@interface DisplayInfoViewController : NSViewController <AddSourceServerViewControllerDelegate, AddSourceServerAccountViewControllerDelegate, ConfirmDeleteViewControllerDelegate, NSTextFieldDelegate>
{
}

@property (nonatomic, weak) id <DisplayInfoViewControllerDelegate> delegate;


@property (weak) IBOutlet OnOffSwitchControlCell *checkBoxEnableStartInterval;
- (IBAction)actionEnableStartInterval:(id)sender;


@property (weak) IBOutlet NSPopUpButton *buttonSelectLogLevel;
- (IBAction)actionSelectLogLevel:(id)sender;

@property (weak) IBOutlet NSTextField *textFieldTimeInterval;
@property (weak) IBOutlet NSButton *buttonSetTimeInterval;
- (IBAction)actionSetTimeInterval:(id)sender;


@property (weak) IBOutlet NSPopUpButton *buttonSelectSSAddress;
@property (weak) IBOutlet NSButton *buttonAddSSAddress;
@property (weak) IBOutlet NSButton *buttonEditSSAddress;
@property (weak) IBOutlet NSButton *buttonDeleteSSAddress;

@property (weak) IBOutlet NSTextField *textFieldSSRequireSSL;
@property (weak) IBOutlet NSTextField *textFieldSSMaxConcurrentOperations;
@property (weak) IBOutlet NSTextField *textFieldSSType;
@property (weak) IBOutlet NSTextField *textFieldSSTCPPort;

@property (weak) IBOutlet NSPopUpButton *buttonSelectSSAccountList;
@property (weak) IBOutlet NSButton *buttonAddSSAccount;
@property (weak) IBOutlet NSButton *buttonEditSSAccount;
@property (weak) IBOutlet NSButton *buttonDeleteSSAccount;

@property (weak) IBOutlet NSTextField *textFieldSSLogin;
@property (weak) IBOutlet NSSecureTextField *textFieldSSPassword;
@property (weak) IBOutlet NSTextField *textFieldTSAccount;
@property (weak) IBOutlet NSTextField *textFieldTSAddress;


- (void)enableOrDisableAllButton:(BOOL)boolValue;

- (IBAction)goAddSourceServerView:(id)sender;
- (IBAction)goEditSourceServerView:(id)sender;


- (IBAction)goAddSoureServerAccountView:(id)sender;
- (IBAction)goEditSourceServerAccountView:(id)sender;

- (IBAction)actionSelectSourceServerAddres:(id)sender;
- (IBAction)actionSelectSourceServerAccount:(id)sender;

- (IBAction)actionDeleteSourceServerAddress:(id)sender;
- (IBAction)actionDeleteSourceServerAccount:(id)sender;

- (void)updatePrefPaneInterfaceTimeInterval;


@end

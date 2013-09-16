//
//  DisplayInfoViewController.m
//  RRMailPrefsPane
//
//  Created by Florian BONNIEC on 9/4/13.
//  Copyright (c) 2013 Florian BONNIEC. All rights reserved.
//

#import "DisplayInfoViewController.h"
#import "RRMConstants.h"

@interface DisplayInfoViewController ()

@property (nonatomic,strong) NSWindow * windowSheet;
@property (nonatomic,strong) IBOutlet AddSourceServerViewController *addSSViewController;
@property (nonatomic,strong) IBOutlet AddSourceServerAccountViewController *addSSAccountViewController;
@property (nonatomic,strong) IBOutlet ConfirmDeleteViewController *confirmDeleteViewController;


@property (nonatomic, strong) NSMutableDictionary *_rrmailConfig;

@property (nonatomic, assign) NSMutableDictionary *_selectedServerConfig;
@property (nonatomic, assign) NSMutableDictionary *_selectedUserConfig;


@end

@implementation DisplayInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        
        [self.textFieldSSRequireSSL setEditable:NO];
        [self.textFieldSSMaxConcurrentOperations setEditable:NO];
        [self.textFieldSSType setEditable:NO];
        [self.textFieldSSTCPPort setEditable:NO];
   
        [self.textFieldSSLogin setEditable:NO];
        [self.textFieldSSPassword setEditable:NO];
        [self.textFieldTSAccount setEditable:NO];
        [self.textFieldTSAddress setEditable:NO];
        
        self.addSSViewController = [[AddSourceServerViewController alloc] initWithNibName:@"AddSourceServerView" bundle:[NSBundle bundleWithIdentifier:@"com.florianbonniec.RRMailPrefsPane"]];
        self.addSSAccountViewController = [[AddSourceServerAccountViewController alloc] initWithNibName:@"AddSourceServerAccountView" bundle:[NSBundle bundleWithIdentifier:@"com.florianbonniec.RRMailPrefsPane"]];
        
        self.confirmDeleteViewController = [[ConfirmDeleteViewController alloc] initWithNibName:@"ConfirmDeleteViewController" bundle:[NSBundle bundleWithIdentifier:@"com.florianbonniec.RRMailPrefsPane"]];
        
        self.windowSheet = [[NSWindow alloc]init];
        
        self._rrmailConfig = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/etc/rrmail.plist"];
        
        [self updatePrefPaneInterfaceTimeInterval];
        
    }
    
    return self;
}

- (void)enableOrDisableAllButton:(BOOL)boolValue
{
    [self.buttonSelectLogLevel setEnabled:boolValue];
    [self.checkBoxEnableStartInterval setEnabled:boolValue];
    [self.textFieldTimeInterval setEnabled:boolValue];
    [self.buttonSetTimeInterval setEnabled:boolValue];
    [self.buttonSelectSSAddress setEnabled:boolValue];
    [self.buttonAddSSAddress setEnabled:boolValue];
    [self.buttonEditSSAddress setEnabled:boolValue];
    [self.buttonDeleteSSAddress setEnabled:boolValue];
    [self.textFieldSSRequireSSL setEnabled:boolValue];
    [self.textFieldSSMaxConcurrentOperations setEnabled:boolValue];
    [self.textFieldSSType setEnabled:boolValue];
    [self.textFieldSSTCPPort setEnabled:boolValue];
    [self.buttonSelectSSAccountList setEnabled:boolValue];
    [self.buttonAddSSAccount setEnabled:boolValue];
    [self.buttonEditSSAccount setEnabled:boolValue];
    [self.buttonDeleteSSAccount setEnabled:boolValue];
    [self.textFieldSSLogin setEnabled:boolValue];
    [self.textFieldSSPassword setEnabled:boolValue];
    [self.textFieldTSAccount setEnabled:boolValue];
    [self.textFieldTSAddress setEnabled:boolValue];
    
    [self.textFieldSSRequireSSL setEditable:NO];
    [self.textFieldSSMaxConcurrentOperations setEditable:NO];
    [self.textFieldSSType setEditable:NO];
    [self.textFieldSSTCPPort setEditable:NO];
    
    [self.textFieldSSLogin setEditable:NO];
    [self.textFieldSSPassword setEditable:NO];
    [self.textFieldTSAccount setEditable:NO];
    [self.textFieldTSAddress setEditable:NO];
        
    [self.textFieldTimeInterval setTarget:self];
    [self.textFieldTimeInterval setAction:@selector(actionSetTimeInterval:)];
    
    if (boolValue == YES) {
        
        if (!self._rrmailConfig)
        {
            [self createRRMailConfigFile];
            self._rrmailConfig = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/etc/rrmail.plist"];
        }
        
        // Collect arguments into an array.
        NSMutableArray *args = [NSMutableArray array];
        [args addObject:@"-checkSchedulerLoading"];
        [args addObject:@"1"];
        
        if ([self.delegate displayInfoViewController:self callRRMailConfigWithParameters:args] == YES)
        {
            [self.checkBoxEnableStartInterval setState:1];
        }
        else
        {
            [self.checkBoxEnableStartInterval setState:0];
        }
    }
    
    [self updatePrefPaneInterfaceTimeInterval];
    
}

  

- (void)updatePrefPaneInterfaceTimeInterval
{

    self._rrmailConfig = nil;
    self._selectedServerConfig = nil;
    self._selectedUserConfig = nil;
    
    self._rrmailConfig = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/etc/rrmail.plist"];

    
    //
    NSError *error = nil;
    NSString *stringPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSLocalDomainMask, YES)objectAtIndex:0];
    NSArray *filePathsArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/LaunchDaemons", stringPath]  error:&error];
    
    if ([filePathsArray indexOfObject:@"com.rrmail.scheduler.plist"] != NSNotFound) {
        
        NSString *path = [NSString stringWithFormat:@"%@/LaunchDaemons/com.rrmail.scheduler.plist", stringPath];
        NSMutableDictionary *savedStock = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
        
        NSNumber * startInterval = [savedStock valueForKey:@"StartInterval"];
        
        [self.textFieldTimeInterval setStringValue:startInterval.stringValue];
    }
    
    //
      NSArray * arrayLogLevel = [NSArray arrayWithObjects:@"Emergency", @"Alert", @"Critical", @"Error", @"Warning", @"Notice", @"Info", @"Debug", nil];
    
    [self.buttonSelectLogLevel removeAllItems];
    [self.buttonSelectLogLevel addItemsWithTitles:arrayLogLevel];
    
    NSNumber * appLogLevel = [self._rrmailConfig valueForKey:@"appLogLevel"];
    
    [self.buttonSelectLogLevel selectItemAtIndex:appLogLevel.intValue];
    
    
    //
    NSArray * arrayServerList = [self._rrmailConfig objectForKey:@"serverList"];
    
    if (arrayServerList && arrayServerList.count != 0) {
        
        if (self.textFieldTimeInterval.isEnabled) {
            [self.buttonEditSSAddress setEnabled:YES];
            [self.buttonDeleteSSAddress setEnabled:YES];
        }

        
        for (int i = 0; i < arrayServerList.count; i++) {
            
            if (i == 0) {
                [self.buttonSelectSSAddress removeAllItems]; 
            }
            
            NSMutableDictionary * _serverConfig = [arrayServerList objectAtIndex:i];

            NSString * strSourceServerAddressKey = [_serverConfig objectForKey:kRRMSourceServerAddressKey];
            [self.buttonSelectSSAddress addItemWithTitle:strSourceServerAddressKey];
            
            if (i == 0) {
                self._selectedServerConfig = _serverConfig;
                [self updateServerConfigDisplay];
            }
        }
    }
    
    else
    {
        [self.buttonSelectSSAddress removeAllItems];
        self._selectedServerConfig = nil;
        [self.buttonEditSSAddress setEnabled:NO];
        [self.buttonDeleteSSAddress setEnabled:NO];
        [self.textFieldSSRequireSSL setStringValue:@""];
        [self.textFieldSSMaxConcurrentOperations setStringValue:@""];
        [self.textFieldSSType setStringValue:@""];
        [self.textFieldSSTCPPort setStringValue:@""];
        
        self._selectedUserConfig = nil;
        [self.buttonAddSSAccount setEnabled:NO];
        [self.buttonEditSSAccount setEnabled:NO];
        [self.buttonDeleteSSAccount setEnabled:NO];
        [self.buttonSelectSSAccountList removeAllItems];
        [self.textFieldSSLogin setStringValue:@""];
        [self.textFieldSSPassword setStringValue:@""];
        [self.textFieldTSAccount setStringValue:@""];
        [self.textFieldTSAddress setStringValue:@""];
    }
}

- (void)updateServerConfigDisplay
{
    NSString * strSourceServerAddressKey = [self._selectedServerConfig objectForKey:kRRMSourceServerAddressKey];
    if (strSourceServerAddressKey) {
        [self.buttonSelectSSAddress selectItemWithTitle:strSourceServerAddressKey];
    }
    
    NSString * strSSL = [self._selectedServerConfig objectForKey:kRRMSourceServerRequireSSLKey];
    if (strSSL) {
        if (strSSL.intValue == 1) {
            [self.textFieldSSRequireSSL setStringValue:@"YES"];
        }
        else
            [self.textFieldSSRequireSSL setStringValue:@"NO"];
    }
    
    NSNumber * numberMaxConcurrentOperations = [self._selectedServerConfig objectForKey:kRRMSourceServerMaxConcurrentOperationsKey];
    if (numberMaxConcurrentOperations) {
        [self.textFieldSSMaxConcurrentOperations setStringValue:numberMaxConcurrentOperations.stringValue];
    }
    
    NSString * strSSType = [self._selectedServerConfig objectForKey:kRRMSourceServerTypeKey];
    if (strSSType) {
        [self.textFieldSSType setStringValue:strSSType];
    }
    
    NSNumber * numberTCPPort = [self._selectedServerConfig objectForKey:kRRMSourceServerTCPPortKey];
    if (numberTCPPort) {
        [self.textFieldSSTCPPort setStringValue:numberTCPPort.stringValue];
    }
    
    NSArray * arrayServerAccountList = [self._selectedServerConfig objectForKey:@"sourceServerAccountList"];
    
    if (arrayServerAccountList && arrayServerAccountList.count != 0) {
        
        if (self.textFieldTimeInterval.isEnabled) {

            [self.buttonEditSSAccount setEnabled:YES];
            [self.buttonDeleteSSAccount setEnabled:YES];
        }
        
        for (int j = 0; j < arrayServerAccountList.count; j++) {
            
            if (j == 0) {
                [self.buttonSelectSSAccountList removeAllItems];
            }
            NSMutableDictionary * _userSettings = [arrayServerAccountList objectAtIndex:j];
            
            NSString *strSourceServerLogin = [_userSettings objectForKey:kRRMSourceServerLoginKey];
            [self.buttonSelectSSAccountList addItemWithTitle:strSourceServerLogin];
            
            if (j == 0) {
                self._selectedUserConfig = _userSettings;
                [self updateUserConfigDisplay];
            }
        }
    }
    else
    {
        self._selectedUserConfig = nil;
        [self.buttonAddSSAccount setEnabled:YES];
        [self.buttonEditSSAccount setEnabled:NO];
        [self.buttonDeleteSSAccount setEnabled:NO];
        [self.buttonSelectSSAccountList removeAllItems];
        [self.textFieldSSLogin setStringValue:@""];
        [self.textFieldSSPassword setStringValue:@""];
        [self.textFieldTSAccount setStringValue:@""];
        [self.textFieldTSAddress setStringValue:@""];
    }
}

- (void)updateUserConfigDisplay
{
    NSString *strSourceServerLogin = [self._selectedUserConfig objectForKey:kRRMSourceServerLoginKey];
    if (strSourceServerLogin) {
        [self.textFieldSSLogin setStringValue:strSourceServerLogin];
        [self.buttonSelectSSAccountList selectItemWithTitle:strSourceServerLogin];
    }
    
    NSString *strSourceServerPassword = [self._selectedUserConfig objectForKey:kRRMSourceServerPasswordKey];
    if (strSourceServerPassword) {
        [self.textFieldSSPassword setStringValue:strSourceServerPassword];
    }
    
    NSString *strTargetServerAccount = [self._selectedUserConfig objectForKey:kRRMTargetServerAccountKey];
    if (strTargetServerAccount) {
        [self.textFieldTSAccount setStringValue:strTargetServerAccount];
    }
    
    NSString * strTargetServerKey = [self._selectedUserConfig objectForKey:kRRMTargetServerKey];
    if (strTargetServerKey) {
        [self.textFieldTSAddress setStringValue:strTargetServerKey];
    }
}

- (IBAction)actionSetTimeInterval:(id)sender
{
    // Collect arguments into an array.
    NSMutableArray *args = [NSMutableArray array];
    [args addObject:@"-intervalTime"];
    [args addObject:self.textFieldTimeInterval.stringValue];
    
    [self.delegate displayInfoViewController:self callRRMailConfigWithParameters:args];
}

- (IBAction)actionSelectLogLevel:(id)sender {
    
    NSArray * arrayLogLevel = [NSArray arrayWithObjects:@"Emergency", @"Alert", @"Critical", @"Error", @"Warning", @"Notice", @"Info", @"Debug", nil];

    
    NSInteger i = [arrayLogLevel indexOfObject:self.buttonSelectLogLevel.titleOfSelectedItem];
    
    [self._rrmailConfig setObject:[NSNumber numberWithInteger:i] forKey:@"appLogLevel"];
    
    [self sendNewRRMailConfig];
}

- (IBAction)goAddSourceServerView:(id)sender
{
    [self.windowSheet setFrame:self.addSSViewController.view.frame display:YES];
    [self.windowSheet.contentView addSubview:self.addSSViewController.view];
    
    [self.addSSViewController setDelegate:self];
    [self.addSSViewController set_serverConfigList:[self._rrmailConfig objectForKey:@"serverList"]];
    [self.addSSViewController updateData];
    
    [NSApp beginSheet:self.windowSheet
       modalForWindow:self.view.window
        modalDelegate:self
       didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
          contextInfo:NULL];
}

- (IBAction)goEditSourceServerView:(id)sender
{
    [self.windowSheet setFrame:self.addSSViewController.view.frame display:YES];
    [self.windowSheet.contentView addSubview:self.addSSViewController.view];
    
    [self.addSSViewController setDelegate:self];
    [self.addSSViewController set_serverConfig:self._selectedServerConfig];
    [self.addSSViewController updateData];
    
    
    [NSApp beginSheet:self.windowSheet
       modalForWindow:self.view.window
        modalDelegate:self
       didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
          contextInfo:NULL];
}


- (IBAction)goAddSoureServerAccountView:(id)sender
{
    [self.windowSheet setFrame:self.addSSAccountViewController.view.frame display:YES];
    [self.windowSheet.contentView addSubview:self.addSSAccountViewController.view];
    
    [self.addSSAccountViewController setDelegate:self];
    [self.addSSAccountViewController set_serverAccountList:[self._selectedServerConfig objectForKey:@"sourceServerAccountList"]];
    [self.addSSAccountViewController updateData];
    
    [NSApp beginSheet:self.windowSheet
       modalForWindow:self.view.window
        modalDelegate:self
       didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
          contextInfo:NULL];
}

- (IBAction)goEditSourceServerAccountView:(id)sender
{
    [self.windowSheet setFrame:self.addSSAccountViewController.view.frame display:YES];
    [self.windowSheet.contentView addSubview:self.addSSAccountViewController.view];
    
    [self.addSSAccountViewController setDelegate:self];
    [self.addSSAccountViewController set_userConfig:self._selectedUserConfig];
    [self.addSSAccountViewController updateData];
    
    
    [NSApp beginSheet:self.windowSheet
       modalForWindow:self.view.window
        modalDelegate:self
       didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
          contextInfo:NULL];
}

- (IBAction)actionSelectSourceServerAddres:(id)sender {
    
    NSArray * arrayServerList = [self._rrmailConfig objectForKey:@"serverList"];
    
    if (arrayServerList && arrayServerList.count != 0) {
        
        for (int i = 0; i < arrayServerList.count; i++) {
            
            NSMutableDictionary * _serverConfig = [arrayServerList objectAtIndex:i];
            
            NSString * strSourceServerAddressKey = [_serverConfig objectForKey:kRRMSourceServerAddressKey];
            
            if ([self.buttonSelectSSAddress.title isEqualToString:strSourceServerAddressKey]) {
            
                self._selectedServerConfig = nil;
                self._selectedServerConfig = _serverConfig;

            }
        }
    }
    
    [self updateServerConfigDisplay];
}

- (IBAction)actionSelectSourceServerAccount:(id)sender {
    
    NSArray * arrayServerAccountList = [self._selectedServerConfig objectForKey:@"sourceServerAccountList"];
    
    if (arrayServerAccountList && arrayServerAccountList.count != 0) {
        
        for (int i = 0; i < arrayServerAccountList.count; i++) {
            
            NSMutableDictionary * _userSettings = [arrayServerAccountList objectAtIndex:i];
            
            NSString *strSourceServerLogin = [_userSettings objectForKey:kRRMSourceServerLoginKey];

            if ([self.buttonSelectSSAccountList.title isEqualToString:strSourceServerLogin]) {
                
                self._selectedUserConfig = nil;
                self._selectedUserConfig = _userSettings;
            }
        }
    }
    
    [self updateUserConfigDisplay];
}

- (IBAction)actionDeleteSourceServerAddress:(id)sender {
   
    [self.windowSheet setFrame:self.confirmDeleteViewController.view.frame display:YES];
    [self.windowSheet.contentView addSubview:self.confirmDeleteViewController.view];
    
    [self.confirmDeleteViewController setDelegate:self];
    [self.confirmDeleteViewController setIsSourceServerAddress:YES];
    [self.confirmDeleteViewController.buttonOk setKeyEquivalent:@"\r"];

    
    [NSApp beginSheet:self.windowSheet
       modalForWindow:self.view.window
        modalDelegate:self
       didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
          contextInfo:NULL];
}

- (IBAction)actionDeleteSourceServerAccount:(id)sender {
    
    [self.windowSheet setFrame:self.confirmDeleteViewController.view.frame display:YES];
    [self.windowSheet.contentView addSubview:self.confirmDeleteViewController.view];
    
    [self.confirmDeleteViewController setDelegate:self];
    [self.confirmDeleteViewController setIsSourceServerAddress:NO];
    [self.confirmDeleteViewController.buttonOk setKeyEquivalent:@"\r"];
    
    
    [NSApp beginSheet:self.windowSheet
       modalForWindow:self.view.window
        modalDelegate:self
       didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
          contextInfo:NULL];
}



- (void)addSourceServerViewController:(AddSourceServerViewController *)controller
{
    [self closeSheet];
    [self.addSSViewController.view removeFromSuperview];

    [self sendNewRRMailConfig];
    
//    [self updatePrefPaneInterfaceTimeInterval];

}

- (void)addSourceServerAccountViewController:(AddSourceServerAccountViewController *)controller
{
    [self closeSheet];
    [self.addSSAccountViewController.view removeFromSuperview];
    
    [self sendNewRRMailConfig];
    
//    [self updatePrefPaneInterfaceTimeInterval];
}

- (void)cancelSourceServerViewController:(AddSourceServerViewController *)controller
{
    [self closeSheet];
    [self.addSSViewController.view removeFromSuperview];
}

- (void)cancelSourceServerAccountViewController:(AddSourceServerAccountViewController *)controller
{
    [self closeSheet];
    [self.addSSAccountViewController.view removeFromSuperview];
}

- (void)closeSheet
{
    [self.windowSheet orderOut:self];
    [NSApp endSheet:self.windowSheet];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	
}

- (void)confirmDeleteAccount:(ConfirmDeleteViewController *)controller isSourceServerAddress:(BOOL)boolValue
{
    [self closeSheet];
    [self.confirmDeleteViewController.view removeFromSuperview];
    
    if (boolValue == YES)
    {
        [[self._rrmailConfig objectForKey:@"serverList"] removeObject:self._selectedServerConfig];
    }
    else
    {
        [[self._selectedServerConfig objectForKey:@"sourceServerAccountList"] removeObject:self._selectedUserConfig];
    }
    
    [self sendNewRRMailConfig];
    
//    [self updatePrefPaneInterfaceTimeInterval];
}

- (void)cancelDeleteAccount:(ConfirmDeleteViewController *)controller
{
    [self closeSheet];
    [self.confirmDeleteViewController.view removeFromSuperview];
}

- (void)sendNewRRMailConfig
{
    NSString * stringErr = nil;
    NSData *data =[NSPropertyListSerialization dataFromPropertyList:self._rrmailConfig
                                                             format:NSPropertyListXMLFormat_v1_0
                                                   errorDescription:&stringErr];
    
    NSString *strValue = [NSString stringWithUTF8String:[data bytes]];
    
    NSLog(@"Mon dic est : %@", strValue);
    
    // Collect arguments into an array.
    NSMutableArray *args = [NSMutableArray array];
    [args addObject:@"-rrmailConfig"];
    [args addObject:strValue];
    
    [self.delegate displayInfoViewController:self callRRMailConfigWithParameters:args];
}

- (IBAction)actionEnableStartInterval:(id)sender {
    
    // Collect arguments into an array.
    NSMutableArray *args = [NSMutableArray array];
    [args addObject:@"-luScheduler"];
    [args addObject:[NSString stringWithFormat:@"%d",[NSNumber numberWithInteger:[self.checkBoxEnableStartInterval state]].intValue]];
    
    [self.delegate displayInfoViewController:self callRRMailConfigWithParameters:args];
}

- (void)controlTextDidChange:(NSNotification *)notification {
    
    NSTextField *textField = [notification object];
    
    NSString * originalString = [[NSString alloc]initWithString:textField.stringValue];
    
    NSMutableString *strippedString = [NSMutableString stringWithCapacity:originalString.length];
    
    NSScanner *scanner = [NSScanner scannerWithString:originalString];
    NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    
    while ([scanner isAtEnd] == NO) {
        NSString *buffer;
        if ([scanner scanCharactersFromSet:numbers intoString:&buffer]) {
            [strippedString appendString:buffer];
            
        } else {
            [scanner setScanLocation:([scanner scanLocation] + 1)];
        }
    }
    [textField setStringValue:strippedString];
}

- (void)createRRMailConfigFile
{
    // Collect arguments into an array.
    NSMutableArray *args = [NSMutableArray array];
    [args addObject:@"-createRRMailConfigFile"];
    [args addObject:@"1"];
    
    [self.delegate displayInfoViewController:self callRRMailConfigWithParameters:args];
}

@end

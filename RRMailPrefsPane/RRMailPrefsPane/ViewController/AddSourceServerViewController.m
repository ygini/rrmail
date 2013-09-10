//
//  AddSourceServerViewController.m
//  RRMailPrefsPane
//
//  Created by Florian BONNIEC on 9/4/13.
//  Copyright (c) 2013 Florian BONNIEC. All rights reserved.
//

#import "AddSourceServerViewController.h"
#import "RRMConstants.h"

@interface AddSourceServerViewController ()

@end

@implementation AddSourceServerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (IBAction)actionAddSourceServer:(id)sender
{
    if (self._serverConfig) {
        [self updateSettings];
        self._serverConfig = nil;
        [self clearAllStrings];
    }
    else
    {
        [self addSettings];
        [self clearAllStrings];
    }
    [self.delegate addSourceServerViewController:self];
}

- (IBAction)actionCancel:(id)sender
{
    if (self._serverConfig) {
        self._serverConfig = nil;
    }
    [self clearAllStrings];
    [self.delegate cancelSourceServerViewController:self];

}

- (void)updateData
{
    [self.buttonSSRequireSSL removeAllItems];
    [self.buttonSSRequireSSL addItemWithTitle:@"YES"];
    [self.buttonSSRequireSSL addItemWithTitle:@"NO"];
    
    [self.buttonSSMaxConcurrentOperations removeAllItems];
    
    for (int i = 1; i <=10; i++) {
        [self.buttonSSMaxConcurrentOperations addItemWithTitle:[NSString stringWithFormat:@"%d", i]];
    }
    
    [self.buttonSSType removeAllItems];
    [self.buttonSSType addItemWithTitle:@"pop3"];
    [self.buttonSSType addItemWithTitle:@"imap"];

    if (self._serverConfig != nil) {
        
        NSString * strSourceServerAddressKey = [self._serverConfig objectForKey:kRRMSourceServerAddressKey];
        if (strSourceServerAddressKey)
        {
            [self.textFieldSSAddress setStringValue:strSourceServerAddressKey];
        }
        
        NSString * strSSL = [self._serverConfig objectForKey:kRRMSourceServerRequireSSLKey];
        if (strSSL) {
            
            if (strSSL.intValue == 1) {
                [self.buttonSSRequireSSL selectItemWithTitle:@"YES"];
            }
            else
                [self.buttonSSRequireSSL selectItemWithTitle:@"NO"];
        }
        
        NSNumber * numberMaxConcurrentOperations = [self._serverConfig objectForKey:kRRMSourceServerMaxConcurrentOperationsKey];
        if (numberMaxConcurrentOperations) {
            [self.buttonSSMaxConcurrentOperations selectItemWithTitle:numberMaxConcurrentOperations.stringValue];            }
        
        NSString * strSSType = [self._serverConfig objectForKey:kRRMSourceServerTypeKey];
        if (strSSType) {
            [self.buttonSSType selectItemWithTitle:strSSType];
        }
        
        NSNumber * numberTCPPort = [self._serverConfig objectForKey:kRRMSourceServerTCPPortKey];
        if (numberTCPPort) {
            [self.textFieldSSTCPPort setStringValue:numberTCPPort.stringValue];
        }
    }
}

- (void)clearAllStrings
{
    [self.textFieldSSAddress setStringValue:@""];
    [self.textFieldSSTCPPort setStringValue:@""];
}

- (void)updateSettings
{
    [self._serverConfig setObject:self.textFieldSSAddress.stringValue forKey:kRRMSourceServerAddressKey];
    [self._serverConfig setObject:[NSNumber numberWithBool:[[self.buttonSSRequireSSL selectedItem]title].boolValue] forKey:kRRMSourceServerRequireSSLKey];
    [self._serverConfig setObject:[NSNumber numberWithInt:[[self.buttonSSMaxConcurrentOperations selectedItem]title].intValue]  forKey:kRRMSourceServerMaxConcurrentOperationsKey];
    [self._serverConfig setObject:self.buttonSSType.selectedItem.title forKey:kRRMSourceServerTypeKey];
    [self._serverConfig setObject:[NSNumber numberWithInt:self.textFieldSSTCPPort.intValue]  forKey:kRRMSourceServerTCPPortKey];

}

- (void)addSettings
{
    NSMutableDictionary * newServerConfig = [[NSMutableDictionary alloc]init];
    
    [newServerConfig setObject:self.textFieldSSAddress.stringValue forKey:kRRMSourceServerAddressKey];
    [newServerConfig setObject:[NSNumber numberWithBool:[[self.buttonSSRequireSSL selectedItem]title].boolValue] forKey:kRRMSourceServerRequireSSLKey];
    [newServerConfig setObject:[NSNumber numberWithInt:[[self.buttonSSMaxConcurrentOperations selectedItem]title].intValue]  forKey:kRRMSourceServerMaxConcurrentOperationsKey];
    [newServerConfig setObject:self.buttonSSType.selectedItem.title forKey:kRRMSourceServerTypeKey];
    [newServerConfig setObject:[NSNumber numberWithInt:self.textFieldSSTCPPort.intValue]  forKey:kRRMSourceServerTCPPortKey];
    [newServerConfig setObject:[[NSMutableArray alloc]init] forKey:kRRMSourceServerAccountListKey];

    
    [self._serverConfigList addObject:newServerConfig];
}



@end

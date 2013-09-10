//
//  AddSourceServerAccountViewController.m
//  RRMailPrefsPane
//
//  Created by Florian BONNIEC on 9/4/13.
//  Copyright (c) 2013 Florian BONNIEC. All rights reserved.
//

#import "AddSourceServerAccountViewController.h"
#import "RRMConstants.h"

@interface AddSourceServerAccountViewController ()

@end

@implementation AddSourceServerAccountViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        
    }
    
    return self;
}

- (IBAction)actionAddSourceServerAccount:(id)sender
{
    if (self._userConfig) {
        [self updateSettings];
        self._userConfig = nil;
        [self clearAllStrings];
    }
    else
    {
        [self addSettings];
        [self clearAllStrings];
    }
   
    [self.delegate addSourceServerAccountViewController:self];
}

- (IBAction)actionCancel:(id)sender
{
    if (self._userConfig) {
        self._userConfig = nil;
    }
    [self clearAllStrings];
    [self.delegate cancelSourceServerAccountViewController:self];
}

- (void)updateData
{
    if (self._userConfig) {
        
        NSString *strSourceServerLogin = [self._userConfig objectForKey:kRRMSourceServerLoginKey];
        if (strSourceServerLogin) {
            [self.textFieldSSLogin setStringValue:strSourceServerLogin];
        }
        
        NSString *strSourceServerPassword = [self._userConfig objectForKey:kRRMSourceServerPasswordKey];
        if (strSourceServerPassword) {
            [self.textFieldSSPassword setStringValue:strSourceServerPassword];
        }
        
        NSString *strTargetServerAccount = [self._userConfig objectForKey:kRRMTargetServerAccountKey];
        if (strTargetServerAccount) {
            [self.textFieldTSAccount setStringValue:strTargetServerAccount];
        }
        
        NSString * strTargetServerKey = [self._userConfig objectForKey:kRRMTargetServerKey];
        if (strTargetServerKey) {
            [self.textFieldTSAddress setStringValue:strTargetServerKey];
        }
        
    }
}

- (void)clearAllStrings
{
    [self.textFieldSSLogin setStringValue:@""];
    [self.textFieldSSPassword setStringValue:@""];
    [self.textFieldTSAccount setStringValue:@""];
    [self.textFieldTSAddress setStringValue:@""];
}

- (void)updateSettings
{
    [self._userConfig setObject:self.textFieldSSLogin.stringValue forKey:kRRMSourceServerLoginKey];
    [self._userConfig setObject:self.textFieldSSPassword.stringValue forKey:kRRMSourceServerPasswordKey];
    [self._userConfig setObject:self.textFieldTSAccount.stringValue forKey:kRRMTargetServerAccountKey];
    [self._userConfig setObject:self.textFieldTSAddress.stringValue forKey:kRRMTargetServerKey];
}

- (void)addSettings
{
    NSMutableDictionary * newUserConfig = [[NSMutableDictionary alloc]init];
    
    [newUserConfig setObject:self.textFieldSSLogin.stringValue forKey:kRRMSourceServerLoginKey];
    [newUserConfig setObject:self.textFieldSSPassword.stringValue forKey:kRRMSourceServerPasswordKey];
    [newUserConfig setObject:self.textFieldTSAccount.stringValue forKey:kRRMTargetServerAccountKey];
    [newUserConfig setObject:self.textFieldTSAddress.stringValue forKey:kRRMTargetServerKey];
    
    [self._serverAccountList addObject:newUserConfig];
}



@end

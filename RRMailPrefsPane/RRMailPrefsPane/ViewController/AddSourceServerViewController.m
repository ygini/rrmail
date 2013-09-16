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

    [self.buttonOk setKeyEquivalent:@"\r"];
//    [self.buttonSSMaxConcurrentOperations removeAllItems];
//    
//    for (int i = 1; i <=10; i++) {
//        [self.buttonSSMaxConcurrentOperations addItemWithTitle:[NSString stringWithFormat:@"%d", i]];
//    }
    
    [self.buttonSSType removeAllItems];
    [self.buttonSSType addItemWithTitle:@"pop3"];
    [self.buttonSSType addItemWithTitle:@"imap"];
    
    [self.textFieldMaxConcurrentOperations setStringValue:@"10"];
    
//    NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc]init];
//    [numberFormatter setNumberStyle:NSNumberFormatterNoStyle];
//    //    [numberFormatter setAllowsFloats:NO];
//    
//    [self.textFieldMaxConcurrentOperations setFormatter:numberFormatter];
//    [self.textFieldSSTCPPort setFormatter:numberFormatter];
    
    
//    self.textFieldSSTCPPort.ise

    if (self._serverConfig != nil) {
        
        NSString * strSourceServerAddressKey = [self._serverConfig objectForKey:kRRMSourceServerAddressKey];
        if (strSourceServerAddressKey)
        {
            [self.textFieldSSAddress setStringValue:strSourceServerAddressKey];
        }
        
        NSString * strSSL = [self._serverConfig objectForKey:kRRMSourceServerRequireSSLKey];
        if (strSSL)
        {
            [self.checkBoxSSRequireSSL setState:strSSL.intValue];
        }
        
        NSNumber * numberMaxConcurrentOperations = [self._serverConfig objectForKey:kRRMSourceServerMaxConcurrentOperationsKey];
        if (numberMaxConcurrentOperations) {
            [self.textFieldMaxConcurrentOperations setStringValue:numberMaxConcurrentOperations.stringValue];

        }
        
        NSString * strSSType = [self._serverConfig objectForKey:kRRMSourceServerTypeKey];
        if (strSSType) {
            [self.buttonSSType selectItemWithTitle:strSSType];
        }
        
        NSNumber * numberTCPPort = [self._serverConfig objectForKey:kRRMSourceServerTCPPortKey];
        if (numberTCPPort) {
            [self.textFieldSSTCPPort setStringValue:numberTCPPort.stringValue];
        }
    }
    else
    {
        [self setCorrectPortUsingSSLConfig];
    }
    
  
}

- (IBAction)actionConfigSSLPort:(id)sender
{    
    [self setCorrectPortUsingSSLConfig];
}

- (IBAction)actionConfigSSType:(id)sender
{
    [self setCorrectPortUsingSSLConfig];
}

- (void)clearAllStrings
{
    [self.textFieldSSAddress setStringValue:@""];
    [self.textFieldSSTCPPort setStringValue:@""];
}

- (void)updateSettings
{
    [self._serverConfig setObject:self.textFieldSSAddress.stringValue forKey:kRRMSourceServerAddressKey];
    [self._serverConfig setObject:[NSNumber numberWithBool:self.checkBoxSSRequireSSL.stringValue.boolValue] forKey:kRRMSourceServerRequireSSLKey];
    [self._serverConfig setObject:[NSNumber numberWithInt:self.textFieldMaxConcurrentOperations.stringValue.intValue]  forKey:kRRMSourceServerMaxConcurrentOperationsKey];
    [self._serverConfig setObject:self.buttonSSType.selectedItem.title forKey:kRRMSourceServerTypeKey];
    [self._serverConfig setObject:[NSNumber numberWithInt:self.textFieldSSTCPPort.intValue]  forKey:kRRMSourceServerTCPPortKey];

}

- (void)addSettings
{
    NSMutableDictionary * newServerConfig = [[NSMutableDictionary alloc]init];
    
    [newServerConfig setObject:self.textFieldSSAddress.stringValue forKey:kRRMSourceServerAddressKey];
    [newServerConfig setObject:[NSNumber numberWithBool:self.checkBoxSSRequireSSL.stringValue.boolValue] forKey:kRRMSourceServerRequireSSLKey];
    [newServerConfig setObject:[NSNumber numberWithInt:self.textFieldMaxConcurrentOperations.stringValue.intValue]  forKey:kRRMSourceServerMaxConcurrentOperationsKey];
    [newServerConfig setObject:self.buttonSSType.selectedItem.title forKey:kRRMSourceServerTypeKey];
    [newServerConfig setObject:[NSNumber numberWithInt:self.textFieldSSTCPPort.intValue]  forKey:kRRMSourceServerTCPPortKey];
    [newServerConfig setObject:[[NSMutableArray alloc]init] forKey:kRRMSourceServerAccountListKey];

    
    [self._serverConfigList addObject:newServerConfig];
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

-(void) setCorrectPortUsingSSLConfig
{
//    NSArray * arrayPorts = @[@"110",@"143",@"995",@"993"];
    
    if (self.checkBoxSSRequireSSL.state == 0)
    {
        if ([self.buttonSSType.selectedItem.title isEqualToString:@"pop3"]) {
            
//            if (![arrayPorts indexOfObject:self.textFieldSSTCPPort.stringValue])
//            {
//                return;
//            }
            [self.textFieldSSTCPPort setStringValue:@"110"];

        }
        else
        {
//            if (![arrayPorts indexOfObject:self.textFieldSSTCPPort.stringValue])
//            {
//                return;
//            }
            [self.textFieldSSTCPPort setStringValue:@"143"];

        }
    }
    else
    {
        if ([self.buttonSSType.selectedItem.title isEqualToString:@"pop3"]) {
//            if (![arrayPorts indexOfObject:self.textFieldSSTCPPort.stringValue])
//            {
//                return;
//            }
            [self.textFieldSSTCPPort setStringValue:@"995"];

        }
        else
        {
//            if (![arrayPorts indexOfObject:self.textFieldSSTCPPort.stringValue])
//            {
//                return;
//            }
            [self.textFieldSSTCPPort setStringValue:@"993"];

        }
    }
}



@end

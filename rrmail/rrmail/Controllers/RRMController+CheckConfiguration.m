//
//  RRMController+CheckConfiguration.m
//  rrmail
//
//  Created by Florian BONNIEC on 8/26/13.
//  Copyright (c) 2013 Yoann Gini. All rights reserved.
//

#import "RRMController+CheckConfiguration.h"
#import "RRMConstants.h"

#import "RRMController_Internal.h"

@implementation RRMController (CheckConfiguration)

-(NSError *)checkConfigurationAndAddDefaults
{
    // Configure LogLevel
    NSNumber * appLogLevel = [_configuration objectForKey:@"appLogLevel"];
    
    if (appLogLevel != nil && appLogLevel.intValue >= 0 && appLogLevel.intValue <= 7) {
        [[CocoaSyslog sharedInstance] setAppLogLevel:appLogLevel.intValue];
    }
    else
    {
        // Set 3 as default value
        [[CocoaSyslog sharedInstance] setAppLogLevel:3];
    }
    
    for (NSMutableDictionary * _serverConfig in [_configuration objectForKey:@"serverList"])
    {
        // Verifications for _serverConfig
        
        // Check for valid Host
        NSString * strSourceServerAddressKey = [_serverConfig objectForKey:kRRMSourceServerAddressKey];

        if (strSourceServerAddressKey != nil) {
            
            if ([self verifyHost:strSourceServerAddressKey] == NO) {
                
                NSError * error = [NSError errorWithDomain:(NSString*)kRRMErrorSourceServerAddressKey
                                                      code:kRRMErrorCodeUnableToReadSourceServerAddressKey
                                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                            [_serverConfig objectForKey:kRRMSourceServerAddressKey], kRRMSourceServerAddressKey,
                                                            nil]];
                
                [[CocoaSyslog sharedInstance] messageLevel3Error:@"[Config Check] Invalid kRRMSourceServerAddressKey %@", [_serverConfig objectForKey:kRRMSourceServerAddressKey]];
                [[CocoaSyslog sharedInstance] messageLevel7Debug:@"[Config Check] RRMail error message: %@", error];
                
                return error;
            }
            else
            {
                [[CocoaSyslog sharedInstance] messageLevel6Info:@"[Config Check] Valid kRRMSourceServerAddressKey %@", [_serverConfig objectForKey:kRRMSourceServerAddressKey]];
            }
        }
        else
        {
            NSError * error = [NSError errorWithDomain:(NSString*)kRRMErrorSourceServerAddressKey
                                                  code:kRRMErrorCodeUnableToReadSourceServerAddressKey
                                              userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                        [_serverConfig objectForKey:kRRMSourceServerAddressKey], kRRMSourceServerAddressKey,
                                                        nil]];
            
            [[CocoaSyslog sharedInstance] messageLevel3Error:@"[Config Check] Invalid kRRMSourceServerAddressKey %@", [_serverConfig objectForKey:kRRMSourceServerAddressKey]];
            [[CocoaSyslog sharedInstance] messageLevel7Debug:@"[Config Check] RRMail error message: %@", error];
                        
            return error;
        }
        
        
        // Check for valid port
        NSNumber * numberMaxConcurrentOperations = [_serverConfig objectForKey:kRRMSourceServerMaxConcurrentOperationsKey];
        
        if (numberMaxConcurrentOperations != nil) {
            if (numberMaxConcurrentOperations.intValue < 1) {
                [_serverConfig setObject:@10 forKey:(NSString *)kRRMSourceServerMaxConcurrentOperationsKey];
            }
        }
        else
        {
            [_serverConfig setObject:@10 forKey:(NSString *)kRRMSourceServerMaxConcurrentOperationsKey];
        }
        
        
        // Check for authentification type
        BOOL requireSSL = YES; // Set YES as default value
        
        NSString * strSSL = [_serverConfig objectForKey:kRRMSourceServerRequireSSLKey];
        
        if (strSSL != nil) {
            if (strSSL.boolValue == NO) {
                requireSSL = NO;
            }
        }
        
        [strSSL release];
        
        
        // Check Source Server Type
        NSString * strSourceServerType = [_serverConfig objectForKey:kRRMSourceServerTypeKey];
        
        if (strSourceServerType != nil) {
            if ([strSourceServerType isEqualToString:(NSString*)kRRMSourceServerTypePOP3Value] || [strSourceServerType isEqualToString:(NSString*)kRRMSourceServerTypeIMAPValue])
            {
                [[CocoaSyslog sharedInstance] messageLevel6Info:@"[Config Check] Valid kRRMSourceServerTypeKey %@", [_serverConfig objectForKey:kRRMSourceServerTypeKey]];
            }
            else
            {
                NSError * error = [NSError errorWithDomain:(NSString*)kRRMErrorSourceServerTypeKey
                                                      code:kRRMErrorCodeUnableToReadSourceServerTypeKey
                                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                            [_serverConfig objectForKey:kRRMSourceServerTypeKey], kRRMSourceServerTypeKey,
                                                            nil]];
                
                [[CocoaSyslog sharedInstance] messageLevel3Error:@"[Config Check] Invalid kRRMSourceServerTypeKey %@", [_serverConfig objectForKey:kRRMSourceServerTypeKey]];
                [[CocoaSyslog sharedInstance] messageLevel7Debug:@"[Config Check] RRMail error message: %@", error];
                                
                return error;

            }
        }
        else
        {
            NSError * error = [NSError errorWithDomain:(NSString*)kRRMErrorSourceServerTypeKey
                                        code:kRRMErrorCodeUnableToReadSourceServerTypeKey
                                    userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                              [_serverConfig objectForKey:kRRMSourceServerTypeKey], kRRMSourceServerTypeKey,
                                              nil]];
            
            [[CocoaSyslog sharedInstance] messageLevel3Error:@"[Config Check] Invalid kRRMSourceServerTypeKey %@", [_serverConfig objectForKey:kRRMSourceServerTypeKey]];
            [[CocoaSyslog sharedInstance] messageLevel7Debug:@"[Config Check] RRMail error message: %@", error];
                        
            return error;
        }
        
        
        // Check for valid port
        NSNumber * numberTCPPort = [_serverConfig objectForKey:kRRMSourceServerTCPPortKey];
        
        if (numberTCPPort != nil) {
            NSCharacterSet *numericOnly = [NSCharacterSet decimalDigitCharacterSet];
            NSCharacterSet *myStringSet = [NSCharacterSet characterSetWithCharactersInString:numberTCPPort.stringValue];
            
            if ([numericOnly isSupersetOfSet: myStringSet])
            {
                //String entirely contains decimal numbers only.
                if (numberTCPPort.intValue >= 1 && numberTCPPort.intValue <= 65535)
                {
                    [[CocoaSyslog sharedInstance] messageLevel6Info:@"[Config Check] Valid kRRMSourceServerTCPPortKey %@", [_serverConfig objectForKey:kRRMSourceServerTCPPortKey]];
                        
                }
                else
                {
                    NSError * error = [NSError errorWithDomain:(NSString*)kRRMErrorSourceServerTCPPortKey
                                                          code:kRRMErrorCodeUnableToReadSourceServerTCPPortKey
                                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                [_serverConfig objectForKey:kRRMSourceServerTCPPortKey], kRRMSourceServerTCPPortKey,
                                                                nil]];
                    
                    [[CocoaSyslog sharedInstance] messageLevel3Error:@"[Config Check] Invalid kRRMSourceServerTCPPortKey %@", [_serverConfig objectForKey:kRRMSourceServerTCPPortKey]];
                    [[CocoaSyslog sharedInstance] messageLevel7Debug:@"[Config Check] RRMail error message: %@", error];
                                        
                    return error;
                    
                }
            }
            else
            {
                NSError * error = [NSError errorWithDomain:(NSString*)kRRMErrorSourceServerTCPPortKey
                                                      code:kRRMErrorCodeUnableToReadSourceServerTCPPortKey
                                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                            [_serverConfig objectForKey:kRRMSourceServerTCPPortKey], kRRMSourceServerTCPPortKey,
                                                            nil]];
                
                [[CocoaSyslog sharedInstance] messageLevel3Error:@"[Config Check] Invalid kRRMSourceServerTCPPortKey %@", [_serverConfig objectForKey:kRRMSourceServerTCPPortKey]];
                [[CocoaSyslog sharedInstance] messageLevel7Debug:@"[Config Check] RRMail error message: %@", error];
                                
                return error;
            }
        }
        else
        {
            
            if ([[_serverConfig objectForKey:kRRMSourceServerTypeKey] isEqualToString:(NSString*)kRRMSourceServerTypePOP3Value]) {
                
                if (requireSSL == NO) {
                    [_serverConfig setObject:@110 forKey:(NSString *)kRRMSourceServerTCPPortKey];
                }
                else
                {
                    [_serverConfig setObject:@995 forKey:(NSString *)kRRMSourceServerTCPPortKey];
                }
            }
            else if ([[_serverConfig objectForKey:kRRMSourceServerTypeKey] isEqualToString:(NSString*)kRRMSourceServerTypeIMAPValue])
            {
                if (requireSSL == NO) {
                    [_serverConfig setObject:@143 forKey:(NSString *)kRRMSourceServerTCPPortKey];
                }
                else
                {
                    [_serverConfig setObject:@993 forKey:(NSString *)kRRMSourceServerTCPPortKey];
                }
            }
        }
        
        [numberTCPPort release];
    
        
        // Check _userSettings configuration
        
        for (NSMutableDictionary * _userSettings in  [_serverConfig objectForKey:@"sourceServerAccountList"])
        {
            // Check for valid kRRMSourceServerLoginKey
            NSString *strSourceServerLogin = [_userSettings objectForKey:kRRMSourceServerLoginKey];

            if (strSourceServerLogin != nil && [strSourceServerLogin rangeOfString:@" "].location == NSNotFound)
            {
                [[CocoaSyslog sharedInstance] messageLevel6Info:@"[Config Check] Valid kRRMSourceServerLoginKey %@", [_userSettings objectForKey:kRRMSourceServerLoginKey]];                
            }
            else
            {
                NSError * error = [NSError errorWithDomain:(NSString*)kRRMErrorSourceServerLoginKey
                                                      code:kRRMErrorCodeUnableToReadSourceServerLoginKey
                                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                            [_userSettings objectForKey:kRRMSourceServerLoginKey], kRRMSourceServerLoginKey,
                                                            nil]];
                
                [[CocoaSyslog sharedInstance] messageLevel3Error:@"[Config Check] Invalid kRRMSourceServerLoginKey %@", [_userSettings objectForKey:kRRMSourceServerLoginKey]];
                [[CocoaSyslog sharedInstance] messageLevel7Debug:@"[Config Check] RRMail error message: %@", error];
                                
                return error;
            }
            
            
            // Check for valid kRRMTargetServerAccountKey
            NSString *strTargetServerAccount = [_userSettings objectForKey:kRRMTargetServerAccountKey];

            if (strTargetServerAccount != nil && [strTargetServerAccount rangeOfString:@" "].location == NSNotFound)
            {
                [[CocoaSyslog sharedInstance] messageLevel6Info:@"[Config Check] Valid kRRMTargetServerAccountKey %@", [_userSettings objectForKey:kRRMSourceServerLoginKey]];
            }
            else
            {
                NSError * error = [NSError errorWithDomain:(NSString*)kRRMErrorTargetServerAccountKey
                                                      code:kRRMErrorCodeUnableToReadTargetServerAccountKey
                                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                            [_userSettings objectForKey:kRRMTargetServerAccountKey], kRRMTargetServerAccountKey,
                                                            nil]];
                
                [[CocoaSyslog sharedInstance] messageLevel3Error:@"[Config Check] Invalid kRRMTargetServerAccountKey %@", [_userSettings objectForKey:kRRMTargetServerAccountKey]];
                [[CocoaSyslog sharedInstance] messageLevel7Debug:@"[Config Check] RRMail error message: %@", error];
                                
                return error;
            }
            
            
            // Check for valid Host
            NSString * strTargetServerKey = [_userSettings objectForKey:kRRMTargetServerKey];
            if (strTargetServerKey == nil) {
                
                //if host is nil set it to "localhost" as default
                strTargetServerKey = @"localhost";
                [_userSettings setObject:strTargetServerKey forKey:(NSString *)kRRMTargetServerKey];
                
                
            }
            
            if ([self verifyHost:strTargetServerKey] == NO) {
               
                NSError * error = [NSError errorWithDomain:(NSString*)kRRMErrorTargetServerKey
                                                      code:kRRMErrorCodeUnableToReadTargetServerKey
                                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                            [_userSettings objectForKey:kRRMTargetServerKey], kRRMTargetServerKey,
                                                            nil]];
                                
                return error;
            }
        
        }
    }
    
    
    
    return nil;
    
}


- (BOOL)verifyHost:(NSString *)_hostName
{
    Boolean result;
    CFHostRef hostRef;
    CFArrayRef addresses;
    NSString *hostname = _hostName;
    
    if (hostname != nil)
    {
        hostRef = CFHostCreateWithName(kCFAllocatorDefault, (CFStringRef)hostname);
        result = CFHostStartInfoResolution(hostRef, kCFHostAddresses, NULL);
        
        // pass an error instead of NULL here to find out why it failed
        if (result == TRUE)
        {
            addresses = CFHostGetAddressing(hostRef, &result);
        }
        
        if (result == TRUE)
        {
            CFRelease(hostRef);
            return YES;
        }
        else
        {
            CFRelease(hostRef);
            return NO;
        }
        
        CFRelease(hostRef);

    }
    return NO;
    
}

@end

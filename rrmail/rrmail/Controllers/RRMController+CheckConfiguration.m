//
//  RRMController+CheckConfiguration.m
//  rrmail
//
//  Created by Florian BONNIEC on 8/26/13.
//  Copyright (c) 2013 Yoann Gini. All rights reserved.
//

#import "RRMController+CheckConfiguration.h"
#import "RRMConstants.h"


@implementation RRMController (CheckConfiguration)

-(NSError *)ccWithConfiguration:(NSDictionary *)_configuration
{
    for (NSDictionary * _serverConfig in [_configuration objectForKey:@"serverList"])
    {
        NSLog(@"%@", _serverConfig);
        
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
                
                NSLog(@"SourceServerAddressKey doesn't work");
                
                return error;
            }
        }
        else
        {
            NSError * error = [NSError errorWithDomain:(NSString*)kRRMErrorSourceServerAddressKey
                                                  code:kRRMErrorCodeUnableToReadSourceServerAddressKey
                                              userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                        [_serverConfig objectForKey:kRRMSourceServerAddressKey], kRRMSourceServerAddressKey,
                                                        nil]];
            
            NSLog(@"SourceServerAddressKey is not configured");
            
            return error;

        }
        
        
        // Check for valid port
        NSNumber * numberMaxConcurrentOperations = [_serverConfig objectForKey:kRRMSourceServerMaxConcurrentOperationsKey];
        
        if (numberMaxConcurrentOperations != nil) {
            if (numberMaxConcurrentOperations.intValue < 1) {
                [_serverConfig setValue:@10 forKey:(NSString *)kRRMSourceServerMaxConcurrentOperationsKey];
            }
        }
        else
        {
            [_serverConfig setValue:@10 forKey:(NSString *)kRRMSourceServerMaxConcurrentOperationsKey];
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
            if ([strSourceServerType isEqualToString:(NSString*)kRRMSourceServerTypePOP3Value] || [strSourceServerType isEqualToString:(NSString*)kRRMSourceServerTypeIMAPValue]) {
                
            }
            else
            {
                NSError * error = [NSError errorWithDomain:(NSString*)kRRMErrorSourceServerTypeKey
                                                      code:kRRMErrorCodeUnableToReadSourceServerTypeKey
                                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                            [_serverConfig objectForKey:kRRMSourceServerTypeKey], kRRMSourceServerTypeKey,
                                                            nil]];
                
                NSLog(@"SourceServerType doesn't seem to be valid");
                
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
            
            NSLog(@"SourceServerType is not configured");
            
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
                if (numberTCPPort.intValue >= 1 && numberTCPPort.intValue <= 65535) {
                    NSLog(@"Valid TCPPort");
                }
                else
                {
                    NSError * error = [NSError errorWithDomain:(NSString*)kRRMErrorSourceServerTCPPortKey
                                                          code:kRRMErrorCodeUnableToReadSourceServerTCPPortKey
                                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                [_serverConfig objectForKey:kRRMSourceServerTCPPortKey], kRRMSourceServerTCPPortKey,
                                                                nil]];
                    
                    NSLog(@"TCPPort must be between 1 & 65535");
                    
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
                
                NSLog(@"Unvalid TCPPort");
                
                return error;
            }
        }
        else
        {
            NSLog(@"type is %@",[_serverConfig objectForKey:kRRMSourceServerTypeKey]);
            
            if ([[_serverConfig objectForKey:kRRMSourceServerTypeKey] isEqualToString:(NSString*)kRRMSourceServerTypePOP3Value]) {
                
                if (requireSSL == NO) {
                    [_serverConfig setValue:@110 forKey:(NSString *)kRRMSourceServerTCPPortKey];
                }
                else
                {
                    [_serverConfig setValue:@995 forKey:(NSString *)kRRMSourceServerTCPPortKey];
                }
            }
            else if ([[_serverConfig objectForKey:kRRMSourceServerTypeKey] isEqualToString:(NSString*)kRRMSourceServerTypeIMAPValue])
            {
                if (requireSSL == NO) {
                    [_serverConfig setValue:@143 forKey:(NSString *)kRRMSourceServerTCPPortKey];
                }
                else
                {
                    [_serverConfig setValue:@993 forKey:(NSString *)kRRMSourceServerTCPPortKey];
                }
            }
        }
        
        [numberTCPPort release];
    
        
        // Check _userSettings configuration
        
        for (NSDictionary * _userSettings in  [_serverConfig objectForKey:@"sourceServerAccountList"])
        {
            // Check for valid kRRMSourceServerLoginKey
            NSString *strSourceServerLogin = [_userSettings objectForKey:kRRMSourceServerLoginKey];
            if (strSourceServerLogin != nil && [strSourceServerLogin rangeOfString:@" "].location == NSNotFound) {
                NSLog(@"Valid username or email");
            }
            else
            {
                NSError * error = [NSError errorWithDomain:(NSString*)kRRMErrorSourceServerLoginKey
                                                      code:kRRMErrorCodeUnableToReadSourceServerLoginKey
                                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                            [_serverConfig objectForKey:kRRMSourceServerLoginKey], kRRMSourceServerLoginKey,
                                                            nil]];
                
                NSLog(@"Unvalid username or email");
                
                return error;
            }
            
            
            // Check for valid kRRMTargetServerAccountKey
            NSString *strTargetServerAccount = [_userSettings objectForKey:kRRMTargetServerAccountKey];
            if (strTargetServerAccount != nil && [strTargetServerAccount rangeOfString:@" "].location == NSNotFound) {
                NSLog(@"Valid username or email");
            }
            else
            {
                NSError * error = [NSError errorWithDomain:(NSString*)kRRMErrorSourceServerLoginKey
                                                      code:kRRMErrorCodeUnableToReadSourceServerLoginKey
                                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                            [_serverConfig objectForKey:kRRMSourceServerLoginKey], kRRMSourceServerLoginKey,
                                                            nil]];
                
                NSLog(@"Unvalid username or email");
                
                return error;
            }
            
            
            // Check for valid Host
            NSString * strTargetServerKey = [_serverConfig objectForKey:kRRMTargetServerKey];
            if (strTargetServerKey == nil) {
                
                //if host is nil set it to "localhost"
                strTargetServerKey = @"localhost";
            }
            
            if ([self verifyHost:strTargetServerKey] == NO) {
               
                NSError * error = [NSError errorWithDomain:(NSString*)kRRMErrorTargetServerKey
                                                      code:kRRMErrorCodeUnableToReadTargetServerKey
                                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                            [_serverConfig objectForKey:kRRMTargetServerKey], kRRMTargetServerKey,
                                                            nil]];
                
                NSLog(@"TargerServerKey doesn't work");
                
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
            NSLog(@"Resolved");
            return YES;
        }
        else
        {
            CFRelease(hostRef);
            NSLog(@"Not resolved");
            return NO;
        }
        

    }
    return NO;
    
}

@end

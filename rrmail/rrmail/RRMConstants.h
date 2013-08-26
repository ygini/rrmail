//
//  RRMConstants.h
//  rrmail
//
//  Created by Yoann Gini on 07/08/13.
//  Copyright (c) 2013 Yoann Gini. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const NSString * kRRMControllerDefaultConfigFile;

extern const NSString * kRRMErrorDomain;

typedef enum {
	kRRMErrorCodeUnableToReadConfigFile = 1000,
    kRRMErrorCodeUnableToReadSourceServerTypeKey = 1001,
    kRRMErrorCodeUnableToReadSourceServerTCPPortKey = 1002,
    kRRMErrorCodeUnableToReadSourceServerLoginKey = 1003,
    kRRMErrorCodeUnableToReadSourceServerAddressKey = 1004,
    kRRMErrorCodeUnableToReadTargetServerKey = 1005

} kRRMErrorCode;


extern const NSString * kRRMErrorFilePathKey;

extern const NSString * kRRMServerListKey;
extern const NSString * kRRMSourceServerAddressKey;
extern const NSString * kRRMSourceServerTypeKey;
extern const NSString * kRRMSourceServerTypePOP3Value;
extern const NSString * kRRMSourceServerTypeIMAPValue;
extern const NSString * kRRMSourceServerRequireSSLKey; // Optional, default yes
extern const NSString * kRRMSourceServerTCPPortKey; // Optional, default related to SSL settings and server type
extern const NSString * kRRMSourceServerMaxConcurrentOperationsKey; // Optional, default 10
extern const NSString * kRRMSourceServerAccountListKey;
extern const NSString * kRRMSourceServerLoginKey;
extern const NSString * kRRMSourceServerPasswordKey;
extern const NSString * kRRMTargetServerAccountKey;
extern const NSString * kRRMTargetServerKey; // Optional, default localhost


// Error configuration plist

extern const NSString * kRRMErrorSourceServerTypeKey;
extern const NSString * kRRMErrorSourceServerTCPPortKey;
extern const NSString * kRRMErrorSourceServerLoginKey;
extern const NSString * kRRMErrorSourceServerAddressKey;
extern const NSString * kRRMErrorTargetServerKey;
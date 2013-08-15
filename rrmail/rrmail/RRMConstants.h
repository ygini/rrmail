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
	kRRMErrorCodeUnableToReadConfigFile = 1000
} kRRMErrorCode;


extern const NSString * kRRMErrorFilePathKey;

extern const NSString * kRRMServerListKey;
extern const NSString * kRRMSourceServerAddressKey;
extern const NSString * kRRMSourceServerTypeKey;
extern const NSString * kRRMSourceServerTypePOP3Value;
extern const NSString * kRRMSourceServerTypeIMAPValue;
extern const NSString * kRRMSourceServerRequireSSLKey; // Optional, default yes
extern const NSString * kRRMSourceServerTCPPortKey; // Optional, default related to SSL settings
extern const NSString * kRRMSourceServerMaxConcurrentOperationsKey; // Optional, default 10
extern const NSString * kRRMSourceServerAccountListKey;
extern const NSString * kRRMSourceServerLoginKey;
extern const NSString * kRRMSourceServerPasswordKey;
extern const NSString * kRRMTargetServerAccountKey;
extern const NSString * kRRMTargetServerKey; // Optional, default localhost

